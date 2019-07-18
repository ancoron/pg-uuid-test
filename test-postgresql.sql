SET application_name TO 'uuid-ext-test';

\timing on

-- INSERT 80M rows...
COPY t_uuid FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

COPY t_uuid_serial FROM '${DATA_DIR}/data.serial.a.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

COPY t_uuid_ext FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

COPY t_uuid_v1 FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);


-- ANALYZE...
ANALYZE VERBOSE t_uuid;
ANALYZE VERBOSE t_uuid_serial;
ANALYZE VERBOSE t_uuid_ext;
ANALYZE VERBOSE t_uuid_v1;
CHECKPOINT;
SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;


-- DELETE first 20M rows...
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_A}';
CHECKPOINT;
SELECT pg_sleep(5);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_serial WHERE id < '${TEST_UUID_A_SERIAL}';
CHECKPOINT;
SELECT pg_sleep(5);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_ext WHERE id <* '${TEST_UUID_A}';
CHECKPOINT;
SELECT pg_sleep(5);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_v1 WHERE id < '${TEST_UUID_A}';
CHECKPOINT;
SELECT pg_sleep(5);


-- ANALYZE...
ANALYZE VERBOSE t_uuid;
ANALYZE VERBOSE t_uuid_serial;
ANALYZE VERBOSE t_uuid_ext;
ANALYZE VERBOSE t_uuid_v1;
CHECKPOINT;
SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;

VACUUM (VERBOSE, ANALYZE) t_uuid;
CHECKPOINT;
SELECT pg_sleep(5);

VACUUM (VERBOSE, ANALYZE) t_uuid_serial;
CHECKPOINT;
SELECT pg_sleep(5);

VACUUM (VERBOSE, ANALYZE) t_uuid_ext;
CHECKPOINT;
SELECT pg_sleep(5);

VACUUM (VERBOSE, ANALYZE) t_uuid_v1;
CHECKPOINT;
SELECT pg_sleep(5);


SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;


-- DELETE first 20M rows...
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}';
CHECKPOINT;
SELECT pg_sleep(5);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_serial WHERE id < '${TEST_UUID_B_SERIAL}';
CHECKPOINT;
SELECT pg_sleep(5);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_ext WHERE id <~ '${TEST_TIMESTAMP_B}';
CHECKPOINT;
SELECT pg_sleep(5);

EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_v1 WHERE id < '${TEST_UUID_B}';
CHECKPOINT;
SELECT pg_sleep(5);


-- INSERT additional 20M rows...
COPY t_uuid FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

COPY t_uuid_serial FROM '${DATA_DIR}/data.serial.b.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

COPY t_uuid_ext FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

COPY t_uuid_v1 FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
CHECKPOINT;
SELECT pg_sleep(5);

-- ANALYZE...
ANALYZE VERBOSE t_uuid;
ANALYZE VERBOSE t_uuid_serial;
ANALYZE VERBOSE t_uuid_ext;
ANALYZE VERBOSE t_uuid_v1;
CHECKPOINT;
SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;

VACUUM (VERBOSE, ANALYZE) t_uuid;
CHECKPOINT;
SELECT pg_sleep(5);

VACUUM (VERBOSE, ANALYZE) t_uuid_serial;
CHECKPOINT;
SELECT pg_sleep(5);

VACUUM (VERBOSE, ANALYZE) t_uuid_ext;
CHECKPOINT;
SELECT pg_sleep(5);

VACUUM (VERBOSE, ANALYZE) t_uuid_v1;
CHECKPOINT;
SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;


REINDEX (VERBOSE) TABLE t_uuid;
CHECKPOINT;
SELECT pg_sleep(5);

REINDEX (VERBOSE) TABLE t_uuid_serial;
CHECKPOINT;
SELECT pg_sleep(5);

REINDEX (VERBOSE) TABLE t_uuid_ext;
CHECKPOINT;
SELECT pg_sleep(5);

REINDEX (VERBOSE) TABLE t_uuid_v1;
CHECKPOINT;
SELECT pg_sleep(5);


SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;

