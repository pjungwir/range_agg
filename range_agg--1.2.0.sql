/* range_agg--1.2.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION range_agg" to load this file. \quit


CREATE OR REPLACE FUNCTION range_agg_transfn(internal, anyrange)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, anyrange)
RETURNS anyrange
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(anyrange) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

-- 2- and 3-parameter versions must be defined for each range type:

-- int4range

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, int4range, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, int4range, boolean)
RETURNS int4range[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(int4range, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, int4range, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, int4range, boolean, boolean)
RETURNS int4range[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(int4range, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

-- int8range

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, int8range, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, int8range, boolean)
RETURNS int8range[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(int8range, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, int8range, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, int8range, boolean, boolean)
RETURNS int8range[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(int8range, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

-- numrange

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, numrange, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, numrange, boolean)
RETURNS numrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(numrange, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, numrange, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, numrange, boolean, boolean)
RETURNS numrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(numrange, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

-- tsrange

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, tsrange, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, tsrange, boolean)
RETURNS tsrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(tsrange, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, tsrange, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, tsrange, boolean, boolean)
RETURNS tsrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(tsrange, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

-- tstzrange

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, tstzrange, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, tstzrange, boolean)
RETURNS tstzrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(tstzrange, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, tstzrange, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, tstzrange, boolean, boolean)
RETURNS tstzrange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(tstzrange, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

-- daterange

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, daterange, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, daterange, boolean)
RETURNS daterange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(daterange, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);

CREATE OR REPLACE FUNCTION range_agg_transfn(internal, daterange, boolean, boolean)
RETURNS internal
AS 'range_agg', 'range_agg_transfn'
LANGUAGE c IMMUTABLE;

CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, daterange, boolean, boolean)
RETURNS daterange[]
AS 'range_agg', 'range_agg_finalfn'
LANGUAGE c IMMUTABLE;

CREATE AGGREGATE range_agg(daterange, boolean, boolean) (
  stype = internal,
  sfunc = range_agg_transfn,
  finalfunc = range_agg_finalfn,
  finalfunc_extra
);
