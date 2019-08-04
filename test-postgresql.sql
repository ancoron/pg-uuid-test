SET application_name TO 'uuid-ext-test';

SELECT pg_backend_pid();

SELECT pg_sleep(30);

\timing on

-- INSERT X rows...
SELECT 't_uuid', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

-- ANALYZE...
SELECT 't_uuid', 'analyze-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
ANALYZE VERBOSE t_uuid;
SELECT 't_uuid', 'analyze-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid', 'select-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid
WHERE uuid_v1_timestamp(id) >= '${TEST_TIMESTAMP_A}' AND uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}'
ORDER BY uuid_v1_timestamp(id) DESC;
SELECT 't_uuid', 'select-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- DELETE first X rows...
SELECT 't_uuid', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_A}';
SELECT 't_uuid', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;





SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_serial FROM '${DATA_DIR}/data.serial.a.txt' WITH ( FORMAT text );
SELECT 't_uuid_serial', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_ext FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid_ext', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_v1 FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid_v1', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- ANALYZE...
SELECT 't_uuid*', 'analyze-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
ANALYZE VERBOSE t_uuid;
ANALYZE VERBOSE t_uuid_serial;
ANALYZE VERBOSE t_uuid_ext;
ANALYZE VERBOSE t_uuid_v1;
SELECT 't_uuid*', 'analyze-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

CHECKPOINT;

SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'select-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_serial
WHERE id >= '${TEST_UUID_A_SERIAL}' AND id < '${TEST_UUID_B_SERIAL}'
ORDER BY id DESC;
SELECT 't_uuid_serial', 'select-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'select-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_ext WHERE id >=~ '${TEST_TIMESTAMP_A}' AND id <~ '${TEST_TIMESTAMP_B}'
ORDER BY id USING <*;
SELECT 't_uuid_ext', 'select-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'select-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_v1
WHERE id >=~ '${TEST_TIMESTAMP_A}' AND id <~ '${TEST_TIMESTAMP_B}'
ORDER BY id DESC;
SELECT 't_uuid_v1', 'select-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- DELETE first X rows...
SELECT 't_uuid', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_A}';
SELECT 't_uuid', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_serial WHERE id < '${TEST_UUID_A_SERIAL}';
SELECT 't_uuid_serial', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_ext WHERE id <* '${TEST_UUID_A}';
SELECT 't_uuid_ext', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_v1 WHERE id < '${TEST_UUID_A}';
SELECT 't_uuid_v1', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid;
SELECT 't_uuid', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_serial;
SELECT 't_uuid_serial', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_ext;
SELECT 't_uuid_ext', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_v1;
SELECT 't_uuid_v1', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;

-- DELETE another X rows...
SELECT pg_sleep(5);

SELECT 't_uuid', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}';
SELECT 't_uuid', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_serial WHERE id < '${TEST_UUID_B_SERIAL}';
SELECT 't_uuid_serial', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_ext WHERE id <~ '${TEST_TIMESTAMP_B}';
SELECT 't_uuid_ext', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_v1 WHERE id < '${TEST_UUID_B}';
SELECT 't_uuid_v1', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_serial FROM '${DATA_DIR}/data.serial.b.txt' WITH ( FORMAT text );
SELECT 't_uuid_serial', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_ext FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid_ext', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_v1 FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid_v1', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_serial TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid_serial', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_ext TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid_ext', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_v1 TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid_v1', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid;
SELECT 't_uuid', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_serial;
SELECT 't_uuid_serial', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_ext;
SELECT 't_uuid_ext', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_v1;
SELECT 't_uuid_v1', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;

SELECT 't_uuid', 'reindex-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
REINDEX (VERBOSE) TABLE t_uuid;
SELECT 't_uuid', 'reindex-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_serial', 'reindex-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
REINDEX (VERBOSE) TABLE t_uuid_serial;
SELECT 't_uuid_serial', 'reindex-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_ext', 'reindex-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
REINDEX (VERBOSE) TABLE t_uuid_ext;
SELECT 't_uuid_ext', 'reindex-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'reindex-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
REINDEX (VERBOSE) TABLE t_uuid_v1;
SELECT 't_uuid_v1', 'reindex-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;
