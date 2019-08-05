#!/bin/bash

PG_PORT=${PG_PORT:-5432}
PG_DATABASE=${PG_DATABASE:-test}

ROWS=${ROWS:-217}
ROWS_DEL_A=7
ROWS_DEL_B=5
ROWS_ADD=17

tmpfile=$(mktemp)
logfile=test-postgresql-v1.log

cleanup()
{
    rm -f $tmpfile
}

error()
{
    echo "$1" >&2
    cleanup
    exit 1
}

path_generator="$1"

num_total=$(($ROWS * 1000000))
offset_del_a=$(($ROWS_DEL_A * 1000000 + 1))
offset_del_b=$(($ROWS_DEL_B * 1000000 + $offset_del_a))
offset_add=$((($ROWS - $ROWS_ADD) * 1000000))
offset_add_first=$(($offset_add + 1))

cat <<EOF
Test configuration:

Total number of UUID's in test: ${num_total}

EOF

if [ -f $logfile ]; then
    echo "Backup log file from previous test run ($(stat --printf='%y' $logfile))"
    mv -v $logfile "$(basename $logfile .log)-$(stat --printf='%Y' $logfile).log"
fi

if [ -f data.v1.a.txt ]; then
    echo "Reusing existing test data..."
else
    [ -d "$path_generator" ] || error "Path to Maven project clone required from: https://github.com/ancoron/java-uuid-serial"

    mvn -f "$path_generator/pom.xml" clean install -Duuids=${num_total} -Dinterval_days=365 -Duuid.historic=true -Duuid.skip.v1=false -Dnodes=9 -Dnodes.time.diff=true || error "Unable to generate UUID data"

    echo "Preparing test data..."
    sed "${offset_add} {q}" "$path_generator/target/uuids.v1.historic.txt" > data.v1.a.txt
    sed -n "${offset_add_first},\$p" "$path_generator/target/uuids.v1.historic.txt" > data.v1.b.txt

    echo "...remove unnecessary files..."
    mvn -f "$path_generator/pom.xml" clean
fi

TEST_UUID_A=$(sed -n "${offset_del_a} {p;q}" data.v1.a.txt)
TEST_UUID_B=$(sed -n "${offset_del_b} {p;q}" data.v1.a.txt)

[ -n "$TEST_UUID_A" ] || error "No UUID selected for tests - please check test data"
[ -n "$TEST_UUID_B" ] || error "No UUID selected for tests - please check test data"

echo "Verifying sudo..."
sudo -u postgres true || error "Initialize sudo for user 'postgres' first"

echo "Preparing database '${PG_DATABASE}' ..."
sudo --non-interactive -u postgres psql --port=${PG_PORT} -1 --file=test-postgresql-v1.setup.sql ${PG_DATABASE} || error "Test setup failed"

TEST_TIMESTAMP_A="$(sudo --non-interactive -u postgres psql --port=${PG_PORT} --tuples-only --no-align -c "SELECT uuid_v1_timestamp('${TEST_UUID_A}'::uuid)" ${PG_DATABASE})"
TEST_TIMESTAMP_B="$(sudo --non-interactive -u postgres psql --port=${PG_PORT} --tuples-only --no-align -c "SELECT uuid_v1_timestamp('${TEST_UUID_B}'::uuid)" ${PG_DATABASE})"

[ -n "$TEST_TIMESTAMP_A" ] || error "No timestamp selected for tests - please check test data"
[ -n "$TEST_TIMESTAMP_B" ] || error "No timestamp selected for tests - please check test data"

DATA_DIR=$(pwd)

# apply variables for test...
export TEST_UUID_A TEST_UUID_B TEST_TIMESTAMP_A TEST_TIMESTAMP_B DATA_DIR
envsubst < test-postgresql-v1.sql > $tmpfile

chmod 644 $tmpfile

echo "Executing tests ..."
sudo --non-interactive -u postgres psql --port=${PG_PORT} --echo-all -P pager=off --file=${tmpfile} ${PG_DATABASE} &>$logfile || error "Test execution failed"

cleanup

echo "Summary:"

sed -n -E 's/^ (t_uuid[^ \|]*)\s*\|\s*([^\|]+)-start\s*\|\s*([^ \|]+)\s*$/\1 \2/p; s/^.*cost.*actual.*rows=([1-9][0-9]+).*$/\1/p; s/^COPY ([0-9]+).*/\1/p; s/^Time: (.* \(.*)/\1;/p' $logfile | \
    tr '\n' ' ' | \
    tr ';' '\n' | \
    sed -n -E 's/( (analyze|vacuum)[^ ]*)/\1 0/; s/^\s*(t_.*)/\1/p' | \
    awk '
BEGIN {
    split("t_uuid,t_uuid_v1,t_uuid_64,t_uuid_32", tables, ",");
    split("copy-in,select-1,analyze-1,select-2,delete-1,vacuum-1,delete-2,copy-add,copy-out,select-3,vacuum-2", sections, ",")
}

{
    rows[$2][$1] = $3;
    millis[$2][$1] = $4;
    hr[$2][$1] = $6;
}

END {
    for (s in sections) {
        section = sections[s];
        printf("\n## %s\n", section);
        for (t in tables) {
            table = tables[t];
            perf_ms = millis[section][table];
            perf = 100.0;
            if (table != "t_uuid") {
                perf = 100.0 / millis[section]["t_uuid"] * perf_ms;
            };
            perf_r = rows[section][table];
            if (perf_r > 0) {
                perf_r = perf_r / perf_ms;
                printf("%-10s %12.3f ms %s %5.1f %% (%4.0fk rows/s)\n", sprintf("%s:", table), perf_ms, hr[section][table], perf, perf_r);
            } else {
                printf("%-10s %12.3f ms %s %5.1f %%\n", sprintf("%s:", table), perf_ms, hr[section][table], perf);
            }
        }
    }
}'

echo "... all done. Please review the logs at: $logfile"
