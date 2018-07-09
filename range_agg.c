#include <postgres.h>
#include <fmgr.h>
#include <catalog/pg_type.h>
#include <utils/array.h>
#include <utils/builtins.h>
#include <utils/lsyscache.h>
#include <utils/typcache.h>
#include <utils/rangetypes.h>
#include <funcapi.h>
// #if PG_VERSION_NUM >= 90500
// #include <utils/arrayaccess.h>
// #endif

PG_MODULE_MAGIC;

#include "util.c"
static int element_compare(const void *key1, const void *key2, void *arg);

typedef struct range_agg_state {
  ArrayBuildState *inputs;
  bool gaps_are_okay;
  bool overlaps_are_okay;
} range_agg_state;

// We can't use the core array_append,
// because we have to capture the second & third parameters
// and put them in the aggregate's running state,
// so that our finalfn can use them.
Datum range_agg_transfn(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(range_agg_transfn);

Datum
range_agg_transfn(PG_FUNCTION_ARGS)
{
  Oid rangeTypeId;
  // Oid rangeBaseTypeId;
  MemoryContext aggContext;
  range_agg_state *state;

  if (!AggCheckCallContext(fcinfo, &aggContext)) {
    elog(ERROR, "range_agg_transfn called in non-aggregate context");
  }

  rangeTypeId = get_fn_expr_argtype(fcinfo->flinfo, 1);
  if (!type_is_range(rangeTypeId)) {
    ereport(ERROR, (errmsg("range_agg must be called with a range")));
  }
  if (PG_ARGISNULL(0)) {
    state = MemoryContextAlloc(aggContext, sizeof(range_agg_state));
    state->inputs = initArrayResult(rangeTypeId, aggContext, false);
    state->gaps_are_okay     = !PG_ARGISNULL(2) && PG_GETARG_BOOL(2);
    state->overlaps_are_okay = !PG_ARGISNULL(3) && PG_GETARG_BOOL(3);
  } else {
    state = (range_agg_state *)PG_GETARG_POINTER(0);
  }

  // Might as well just skip NULLs here so the finalfn doesn't have to:
  if (!PG_ARGISNULL(1)) {
    accumArrayResult(state->inputs, PG_GETARG_DATUM(1), false, rangeTypeId, aggContext);
  }
  PG_RETURN_POINTER(state);
}


Datum range_agg_finalfn(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(range_agg_finalfn);

Datum
range_agg_finalfn(PG_FUNCTION_ARGS)
{
  MemoryContext aggContext;

  Oid rangeTypeId;
  TypeCacheEntry *typcache;

  range_agg_state *state;
  ArrayBuildState *inputArray;
  int inputLength;
  Datum *inputVals;
  bool *inputNulls;

  int i;
  RangeType *currentRange;
  RangeType *lastRange;
  char *r1Str, *r2Str;

  ArrayBuildState *resultContent;
  Datum result;

  if (!AggCheckCallContext(fcinfo, &aggContext)) {
    elog(ERROR, "range_agg_finalfn called in non-aggregate context");
  }

  state = PG_ARGISNULL(0) ? NULL : (range_agg_state *)PG_GETARG_POINTER(0);
  if (state == NULL) PG_RETURN_NULL();
  inputArray  = state->inputs;
  inputVals   = inputArray->dvalues;
  inputNulls  = inputArray->dnulls;
  inputLength = inputArray->nelems;
  rangeTypeId = inputArray->element_type;

  typcache = range_get_typcache(fcinfo, rangeTypeId);
  if (inputLength == 0) PG_RETURN_NULL();
  qsort_arg(inputVals, inputLength, sizeof(Datum), element_compare, typcache);

  resultContent = initArrayResult(rangeTypeId, aggContext, false);
  lastRange = DatumGetRangeType(inputVals[0]);
  for (i = 1; i < inputLength; i++) {
    Assert(inputNulls[i]);
    currentRange = DatumGetRangeType(inputVals[i]);
    // N.B. range_adjacent_internal gives true
    // if *either* A meets B OR B meets A,
    // which is not quite what we want,
    // but we rely on the sorting above to rule out B meets A ever happening.
    if (range_adjacent_internal(typcache, lastRange, currentRange)) {
      lastRange = range_union_internal(typcache, lastRange, currentRange, false);

    } else if (range_before_internal(typcache, lastRange, currentRange)) {
      if (!state->gaps_are_okay) {
        r1Str = "lastRange"; r2Str = "currentRange";
        // TODO: Why is this segfaulting?:
        // r1Str = DatumGetCString(DirectFunctionCall1(range_out, RangeTypeGetDatum(lastRange)));
        // r2Str = DatumGetCString(DirectFunctionCall1(range_out, RangeTypeGetDatum(currentRange)));
        ereport(ERROR, (errmsg("range_agg: gap detected between %s and %s", r1Str, r2Str)));
      }
      accumArrayResult(resultContent, RangeTypeGetDatum(lastRange), false, rangeTypeId, aggContext);
      lastRange = currentRange;
      
    } else {  // they must overlap
      if (!state->overlaps_are_okay) {
        r1Str = "lastRange"; r2Str = "currentRange";
        // TODO: Why is this segfaulting?:
        // r1Str = DatumGetCString(DirectFunctionCall1(range_out, RangeTypeGetDatum(lastRange)));
        // r2Str = DatumGetCString(DirectFunctionCall1(range_out, RangeTypeGetDatum(currentRange)));
        ereport(ERROR, (errmsg("range_agg: overlap detected between %s and %s", r1Str, r2Str)));
      }
      lastRange = range_union_internal(typcache, lastRange, currentRange, false);
    }
  }
  accumArrayResult(resultContent, RangeTypeGetDatum(lastRange), false, rangeTypeId, aggContext);

  if (type_is_array(get_fn_expr_rettype(fcinfo->flinfo))) {
    result = makeArrayResult(resultContent, CurrentMemoryContext);
    PG_RETURN_DATUM(result);
  } else {
    PG_RETURN_DATUM(RangeTypeGetDatum(lastRange));
  }
}

static int element_compare(const void *key1, const void *key2, void *arg) {
  Datum *d1 = (Datum *)key1;
  Datum *d2 = (Datum *)key2;
  RangeType *r1 = DatumGetRangeType(*d1);
  RangeType *r2 = DatumGetRangeType(*d2);
  TypeCacheEntry *typcache = (TypeCacheEntry *) arg;
  RangeBound lower1, lower2;
  RangeBound upper1, upper2;
  bool empty1, empty2;
  int cmp;

  range_deserialize(typcache, r1, &lower1, &upper1, &empty1);
  range_deserialize(typcache, r2, &lower2, &upper2, &empty2);

  if (empty1 && empty2) cmp = 0;
  else if (empty1) cmp = -1;
  else if (empty2) cmp = 1;
  else {
    cmp = range_cmp_bounds(typcache, &lower1, &lower2);
    if (cmp == 0) cmp = range_cmp_bounds(typcache, &upper1, &upper2);
  }

  return cmp;
}
