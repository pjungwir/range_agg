`range_agg`
===========

This is a Postgres extension that provides a `range_agg` aggregate function.
It takes any [Postgres range type](https://www.postgresql.org/docs/current/static/rangetypes.html)
and combines them, sort of like
[`string_agg`, `array_agg`, `json_agg`, etc](https://www.postgresql.org/docs/current/static/functions-aggregate.html).

There are two forms, depending on whether or not you want to permit gaps & overlaps.
If you call `range_agg(anyrange)` (with just a single range parameter),
then it will raise an error if a gap or overlap is detected,
and on success it will return a single range.

You call also call `range_agg(r anyrange, permit_gaps boolean, permit_overlaps boolean)`,
and it will return an *array* of ranges.
It will still merge adjacent/overlapping ranges as much as possible,
but it will add a new array element whenever there is a gap.
So if your group had these ranges:

    [2018-07-01,2018-07-15)
    [2018-07-15,2018-07-31)
    [2018-09-01,2018-09-15)

Then you would get back:

    {"[2018-07-01,2018-07-31)", "[2018-09-01,2018-09-15)"}

You can also choose to raise an exception
on either an overlap or a gap,
by setting the respective parameter to `false`.

Finally there is a two-param version,
`range_agg(r anyrange, permit_gaps boolean)`,
which will raise on overlaps but permits gaps (if passed `true`).
This is likely most useful for coalescing rows in a temporal table (see below).

With temporal databases
-----------------------

The primary motivation of this extension is to let you "coalesce" rows in a temporal database,
as described in section 6.5.2 of Snodgrass's book
[Developing Time-Oriented Database Applications in SQL](https://www2.cs.arizona.edu/~rts/publications.html).
You can use the three-param version of the function to permit gaps
(still forbidding overlaps if you like),
and then `UNNEST` on the resulting range array, like so:

    SELECT  room_id, t2.booked_during
    FROM    ( 
              SELECT  room_id, range_agg(booked_during, true) AS booked_during
              FROM    reservations
              GROUP BY room_id
            ) AS t1,
            UNNEST(t1.booked_during) AS t2(booked_during)
    ORDER BY room_id, booked_during
    ;
     room_id |      booked_during      
    ---------+-------------------------
           1 | [07-01-2018,07-14-2018)
           1 | [07-20-2018,07-22-2018)
           2 | [07-01-2018,07-03-2018)
           5 | [07-01-2018,07-03-2018)
           6 | [07-01-2018,07-10-2018)
           7 | [07-01-2018,07-14-2018)
    (6 rows)


Custom Ranges
-------------

There is a small caveat about using custom range types.
The one-parameter version of `range_agg` will support them automatically,
but the two- and three-parameter versions take a little more work.
[Postgres has no way to declare a function that takes `anyrange` and returns `anyrange[]`](https://www.postgresql.org/message-id/CA%2BrenyVOjb4xQZGjdCnA54-1nzVSY%2B47-h4nkM-EP5J%3D1z%3Db9w%40mail.gmail.com),
so we have separate declarations for `int4range`, `int8range`, etc.
Out of the box we support all built-in range types.
If you want to support a new one, e.g. `inetrange`, just run these commands
(after creating the extension):

    CREATE OR REPLACE FUNCTION range_agg_transfn(internal, inetrange, boolean)
    RETURNS internal
    AS 'range_agg', 'range_agg_transfn'
    LANGUAGE c IMMUTABLE;

    CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, inetrange, boolean)
    RETURNS inetrange[]
    AS 'range_agg', 'range_agg_finalfn'
    LANGUAGE c IMMUTABLE;

    CREATE AGGREGATE range_agg(inetrange, boolean) (
      stype = internal,
      sfunc = range_agg_transfn,
      finalfunc = range_agg_finalfn,
      finalfunc_extra
    );

    CREATE OR REPLACE FUNCTION range_agg_transfn(internal, inetrange, boolean, boolean)
    RETURNS internal
    AS 'range_agg', 'range_agg_transfn'
    LANGUAGE c IMMUTABLE;

    CREATE OR REPLACE FUNCTION range_agg_finalfn(internal, inetrange, boolean, boolean)
    RETURNS inetrange[]
    AS 'range_agg', 'range_agg_finalfn'
    LANGUAGE c IMMUTABLE;

    CREATE AGGREGATE range_agg(inetrange, boolean, boolean) (
      stype = internal,
      sfunc = range_agg_transfn,
      finalfunc = range_agg_finalfn,
      finalfunc_extra
    );


(Replace `inetrange` with your own range type, of course.)


Installing
----------

This package installs like any Postgres extension. First say:

    make && sudo make install

You will need to have `pg_config` in your path,
but normally that is already the case.
You can check with `which pg_config`.

Then in the database of your choice say:

    CREATE EXTENSION range_agg;


TODO
----

- Add a function to find gaps (see below).


Author
------

Paul A. Jungwirth <pj@illuminatedcomputing.com>

This extension was inspired by a blog post about aggregating ranges by [Matt Schinckel](http://schinckel.net/2014/11/18/aggregating-ranges-in-postgres/).
He talks about merging ranges (like we do here)
and a related problem---finding the gaps between them---which I think would be nice to support here too. (Watch this space for updates. :-)
I was impressed by his solution,
which is original as far as I know,
of using [the `lead` window function](https://www.postgresql.org/docs/current/static/functions-window.html).


License
-------

Copyright (c) 2018 Paul A. Jungwirth

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
