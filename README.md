# pg-uuid-test

Some load/stress tests with comparison for UUID's in PostgreSQL.


# Requirements

The following tools are required:

- a running PostgreSQL server (should be version 9.6 or higher)
- [tablespaces][1] `fast` and `faster` configured in PostgreSQL (preferrably on different physical media)
- extension [`uuid_ext`][2] installed
- [java-uuid-serial][3] UUID generator project cloned (and [Maven][4] to be able to build it)

Furthermore, it is required that the directory where the script is run from is at least
readable by system user `postgres` and that the file-system as at least 15 GiB free
space for the test data.

The main test script assumes that we can use `sudo` to user `postgres` for executing
commands using the standard tool `psql`. It is also assumed that the first execution
of `sudo` will create a authentication session as further invocations of `sudo` do
not ask for a password again.

The TCP port of the local PostgreSQL server instance is assumed to be `5432` and the
database used defaults to `test`.


# Execution

To execute the tests, simply do:

```bash
./test-postgresql.sh <path-to-java-uuid-serial>
```

The PostgreSQL port can be configured by environment variable `PG_PORT` and the database with `PG_DATABASE`, e.g. in a one-liner:

```bash
PG_PORT=5433 PG_DATABASE=uuid_tests ./test-postgresql.sh ~/dev/github/java-uuid-serial
```

# Output

The tests will output everything to the file `test-postgresql.log` in the current
working directory, which will include also verbose output and query timing from
`psql` commands:

```
...
psql:/tmp/tmp.UVAkhpgMEN:50: INFO:  analyzing "public.uuid_v1_ext"
psql:/tmp/tmp.UVAkhpgMEN:50: INFO:  "uuid_v1_ext": scanned 150000 of 432433 pages, containing 20780865 live rows and 0 dead rows; 150000 rows in sample, 59908879 estimated total r
ows
VACUUM
Time: 29385.872 ms (00:29.386)
SELECT pg_sleep(90);
 pg_sleep 
----------
 
(1 row)

Time: 90078.580 ms (01:30.079)
SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;
 table_name  |      bloat      | index_mb | table_mb 
-------------+-----------------+----------+----------
 uuid_v1     | 1517 MiB (49 %) | 3123.578 | 3378.383
 uuid_serial | 800 MiB (33 %)  | 2406.453 | 3378.383
 uuid_v1_ext | 800 MiB (33 %)  | 2406.453 | 3378.383
(3 rows)

Time: 242.072 ms
-- DELETE first 20M rows...
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_v1 WHERE uuid_v1_timestamp(id) < '2018-12-02 10:54:57.760554+01';
                                                               QUERY PLAN                                                               
----------------------------------------------------------------------------------------------------------------------------------------
 Delete on public.uuid_v1  (cost=0.00..1331381.62 rows=19976636 width=6) (actual time=26812.986..26812.986 rows=0 loops=1)
   Buffers: shared hit=20157216 read=383329 dirtied=108113 written=69
   I/O Timings: read=6475.798 write=0.784
   ->  Seq Scan on public.uuid_v1  (cost=0.00..1331381.62 rows=19976636 width=6) (actual time=531.651..11727.505 rows=20000003 loops=1)
         Output: ctid
         Filter: (uuid_v1_timestamp(uuid_v1.id) < '2018-12-02 10:54:57.760554+01'::timestamp with time zone)
         Rows Removed by Filter: 39999998
         Buffers: shared hit=49104 read=383329 written=69
         I/O Timings: read=6475.798 write=0.784
 Planning Time: 0.274 ms
 Execution Time: 26813.013 ms
(11 rows)

Time: 26816.459 ms (00:26.816)
...
```


[1]: https://www.postgresql.org/docs/current/sql-createtablespace.html
[2]: https://github.com/ancoron/pg-uuid-ext
[3]: https://github.com/ancoron/java-uuid-serial
[4]: https://maven.apache.org/
