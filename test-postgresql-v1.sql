SET application_name TO 'uuid-v1-test';

SELECT pg_backend_pid();

SELECT pg_sleep(30);

\timing on

/*******************************************************************************
 *
 * TEST: uuid
 *
 ******************************************************************************/

-- INSERT X rows...
SELECT 't_uuid', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid', 'select-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid
WHERE uuid_v1_timestamp(id) >= '${TEST_TIMESTAMP_A}' AND uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}'
ORDER BY uuid_v1_timestamp(id) DESC;
SELECT 't_uuid', 'select-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- ANALYZE...
SELECT 't_uuid', 'analyze-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
ANALYZE VERBOSE t_uuid;
SELECT 't_uuid', 'analyze-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid', 'select-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid
WHERE uuid_v1_timestamp(id) >= '${TEST_TIMESTAMP_A}' AND uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}'
ORDER BY uuid_v1_timestamp(id) DESC;
SELECT 't_uuid', 'select-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- DELETE first X rows...
SELECT 't_uuid', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_A}';
SELECT 't_uuid', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- VACUUM...
SELECT 't_uuid', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid;
SELECT 't_uuid', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- DELETE another X rows...
SELECT 't_uuid', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid WHERE uuid_v1_timestamp(id) < '${TEST_TIMESTAMP_B}';
SELECT 't_uuid', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- INSERT another X rows...
SELECT 't_uuid', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- OUTPUT all rows
SELECT 't_uuid', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT last month...
SELECT 't_uuid', 'select-3-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT COUNT(*) FROM t_uuid
WHERE uuid_v1_timestamp(id) >= (CURRENT_TIMESTAMP - '1 month'::interval);
SELECT 't_uuid', 'select-3-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- VACUUM...
SELECT 't_uuid', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid;
SELECT 't_uuid', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;


-- let the system cam down a bit...
SELECT pg_sleep(60);

/*******************************************************************************
 *
 * TEST: uuid_v1
 *
 ******************************************************************************/
SELECT 't_uuid_v1', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_v1 FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid_v1', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid_v1', 'select-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_v1
WHERE id >=~ '${TEST_TIMESTAMP_A}' AND id <~ '${TEST_TIMESTAMP_B}'
ORDER BY id DESC;
SELECT 't_uuid_v1', 'select-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- ANALYZE...
SELECT 't_uuid_v1', 'analyze-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
ANALYZE VERBOSE t_uuid_v1;
SELECT 't_uuid_v1', 'analyze-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid_v1', 'select-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_v1
WHERE id >=~ '${TEST_TIMESTAMP_A}' AND id <~ '${TEST_TIMESTAMP_B}'
ORDER BY id DESC;
SELECT 't_uuid_v1', 'select-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_v1 WHERE id < '${TEST_UUID_A}';
SELECT 't_uuid_v1', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_v1;
SELECT 't_uuid_v1', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_v1 WHERE id < '${TEST_UUID_B}';
SELECT 't_uuid_v1', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_v1 FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid_v1', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_v1 TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid_v1', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT last month...
SELECT 't_uuid_v1', 'select-3-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT COUNT(*) FROM t_uuid_v1
WHERE id >=~ (CURRENT_TIMESTAMP - '1 month'::interval);
SELECT 't_uuid_v1', 'select-3-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_v1', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_v1;
SELECT 't_uuid_v1', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;


-- let the system cam down a bit...
SELECT pg_sleep(60);

/*******************************************************************************
 *
 * TEST: uuid_int64
 *
 ******************************************************************************/
SELECT 't_uuid_64', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_64 FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid_64', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid_64', 'select-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_64
WHERE id >= uuid_generate_v1_at('${TEST_TIMESTAMP_A}')::uuid_int64 AND id < uuid_generate_v1_at('${TEST_TIMESTAMP_B}')::uuid_int64
ORDER BY id DESC;
SELECT 't_uuid_64', 'select-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- ANALYZE...
SELECT 't_uuid_64', 'analyze-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
ANALYZE VERBOSE t_uuid_64;
SELECT 't_uuid_64', 'analyze-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid_64', 'select-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_64
WHERE id >= uuid_generate_v1_at('${TEST_TIMESTAMP_A}')::uuid_int64 AND id < uuid_generate_v1_at('${TEST_TIMESTAMP_B}')::uuid_int64
ORDER BY id DESC;
SELECT 't_uuid_64', 'select-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_64', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_64 WHERE id < uuid_generate_v1_at('${TEST_TIMESTAMP_A}')::uuid_int64;
SELECT 't_uuid_64', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_64', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_64;
SELECT 't_uuid_64', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_64', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_64 WHERE id < uuid_generate_v1_at('${TEST_TIMESTAMP_B}')::uuid_int64;
SELECT 't_uuid_64', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_64', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_64 FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid_64', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_64', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_64 TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid_64', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT last month...
SELECT 't_uuid_64', 'select-3-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT COUNT(*) FROM t_uuid_64
WHERE id >= uuid_generate_v1_at(CURRENT_TIMESTAMP - '1 month'::interval)::uuid_int64;
SELECT 't_uuid_64', 'select-3-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_64', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_64;
SELECT 't_uuid_64', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;


-- let the system cam down a bit...
SELECT pg_sleep(60);

/*******************************************************************************
 *
 * TEST: uuid_int32
 *
 ******************************************************************************/
SELECT 't_uuid_32', 'copy-in-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_32 FROM '${DATA_DIR}/data.v1.a.txt' WITH ( FORMAT text );
SELECT 't_uuid_32', 'copy-in-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid_32', 'select-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_32
WHERE id >= uuid_generate_v1_at('${TEST_TIMESTAMP_A}')::uuid_int32 AND id < uuid_generate_v1_at('${TEST_TIMESTAMP_B}')::uuid_int32
ORDER BY id DESC;
SELECT 't_uuid_32', 'select-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- ANALYZE...
SELECT 't_uuid_32', 'analyze-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
ANALYZE VERBOSE t_uuid_32;
SELECT 't_uuid_32', 'analyze-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

-- SELECT time range...
SELECT 't_uuid_32', 'select-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM t_uuid_32
WHERE id >= uuid_generate_v1_at('${TEST_TIMESTAMP_A}')::uuid_int32 AND id < uuid_generate_v1_at('${TEST_TIMESTAMP_B}')::uuid_int32
ORDER BY id DESC;
SELECT 't_uuid_32', 'select-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_32', 'delete-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_32 WHERE id < uuid_generate_v1_at('${TEST_TIMESTAMP_A}')::uuid_int32;
SELECT 't_uuid_32', 'delete-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_32', 'vacuum-1-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_32;
SELECT 't_uuid_32', 'vacuum-1-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_32', 'delete-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) DELETE FROM t_uuid_32 WHERE id < uuid_generate_v1_at('${TEST_TIMESTAMP_B}')::uuid_int32;
SELECT 't_uuid_32', 'delete-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_32', 'copy-add-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_32 FROM '${DATA_DIR}/data.v1.b.txt' WITH ( FORMAT text );
SELECT 't_uuid_32', 'copy-add-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT 't_uuid_32', 'copy-out-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
COPY t_uuid_32 TO '/dev/null' WITH ( FORMAT text );
SELECT 't_uuid_32', 'copy-out-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

-- SELECT last month...
SELECT 't_uuid_32', 'select-3-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT COUNT(*) FROM t_uuid_32
WHERE id >= uuid_generate_v1_at(CURRENT_TIMESTAMP - '1 month'::interval)::uuid_int32;
SELECT 't_uuid_32', 'select-3-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);

SELECT pg_sleep(5);

SELECT 't_uuid_32', 'vacuum-2-start', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
VACUUM (VERBOSE, ANALYZE) t_uuid_32;
SELECT 't_uuid_32', 'vacuum-2-end', EXTRACT(EPOCH FROM CURRENT_TIMESTAMP);
CHECKPOINT;

SELECT pg_sleep(5);

SELECT table_name, index_name, concat(bloat_mb, ' MiB (', bloat_pct, ' %)') AS bloat, index_mb, table_mb FROM view_index_bloat WHERE table_name LIKE 't_uuid%' ORDER BY table_name, index_name DESC;
