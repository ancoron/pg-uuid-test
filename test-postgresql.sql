SET application_name TO 'uuid-ext-test';

\timing on

-- INSERT 80M rows...
COPY uuid_v1 FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT pg_sleep(90);

COPY uuid_serial FROM '${DATA_DIR}/data.serial.a.txt' WITH ( FORMAT text );
SELECT pg_sleep(90);

COPY uuid_v1_ext FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT pg_sleep(90);


-- ANALYZE...
ANALYZE VERBOSE uuid_v1;
ANALYZE VERBOSE uuid_serial;
ANALYZE VERBOSE uuid_v1_ext;

SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;
SELECT pg_sleep(90);


-- DELETE first 20M rows...
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_v1 WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_A}';
SELECT pg_sleep(90);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_serial WHERE id < '${TEST_UUID_A_SERIAL}';
SELECT pg_sleep(90);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_v1_ext WHERE id <* '${TEST_UUID_A}';
SELECT pg_sleep(90);


-- ANALYZE...
ANALYZE VERBOSE uuid_v1;
ANALYZE VERBOSE uuid_serial;
ANALYZE VERBOSE uuid_v1_ext;

SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;
SELECT pg_sleep(90);

VACUUM (VERBOSE, ANALYZE) uuid_v1;
SELECT pg_sleep(90);

VACUUM (VERBOSE, ANALYZE) uuid_serial;
SELECT pg_sleep(90);

VACUUM (VERBOSE, ANALYZE) uuid_v1_ext;
SELECT pg_sleep(90);


SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;


-- DELETE first 20M rows...
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_v1 WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}';
SELECT pg_sleep(90);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_serial WHERE id < '${TEST_UUID_B_SERIAL}';
SELECT pg_sleep(90);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM uuid_v1_ext WHERE id <~ '${TEST_TIMESTAMP_B}';
SELECT pg_sleep(90);


-- INSERT additional 20M rows...
COPY uuid_v1 FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT pg_sleep(90);

COPY uuid_serial FROM '${DATA_DIR}/data.serial.b.txt' WITH ( FORMAT text );
SELECT pg_sleep(90);

COPY uuid_v1_ext FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT pg_sleep(90);

-- ANALYZE...
ANALYZE VERBOSE uuid_v1;
ANALYZE VERBOSE uuid_serial;
ANALYZE VERBOSE uuid_v1_ext;

SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;
SELECT pg_sleep(90);

VACUUM (VERBOSE, ANALYZE) uuid_v1;
SELECT pg_sleep(90);

VACUUM (VERBOSE, ANALYZE) uuid_serial;
SELECT pg_sleep(90);

VACUUM (VERBOSE, ANALYZE) uuid_v1_ext;

SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;
SELECT pg_sleep(90);


REINDEX (VERBOSE) TABLE uuid_v1;
SELECT pg_sleep(90);

REINDEX (VERBOSE) TABLE uuid_serial;
SELECT pg_sleep(90);

REINDEX (VERBOSE) TABLE uuid_v1_ext;


SELECT table_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE index_name LIKE '%uuid%' ORDER BY index_name DESC;

