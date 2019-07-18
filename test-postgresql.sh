#!/bin/bash

PG_PORT=${PG_PORT:-5432}
PG_DATABASE=${PG_DATABASE:-test}

ROWS=217
ROWS_DEL_A=7
ROWS_DEL_B=5
ROWS_ADD=17

tmpfile=$(mktemp)
logfile=test-postgresql.log

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

if [ -f data.serial.a.txt ]; then
    echo "Reusing existing test data..."
else
    [ -d "$path_generator" ] || error "Path to Maven project clone required from: https://github.com/ancoron/java-uuid-serial"

    mvn -f "$path_generator/pom.xml" clean install -Duuids=${num_total} -Dinterval_days=365 -Duuid.historic=true -Duuid.skip.v1=false -Dnodes=9 || error "Unable to generate UUID data"

    echo "Preparing test data..."
    sed "${offset_add} {q}" "$path_generator/target/uuids.v1.historic.txt" > data.v1.a.txt
    sed -n "${offset_add_first},\$p" "$path_generator/target/uuids.v1.historic.txt" > data.v1.b.txt
    sed "${offset_add} {q}" "$path_generator/target/uuids.serial.historic.txt" > data.serial.a.txt
    sed -n "${offset_add_first},\$p" "$path_generator/target/uuids.serial.historic.txt" > data.serial.b.txt

    echo "...remove unnecessary files..."
    mvn -f "$path_generator/pom.xml" clean
fi

TEST_UUID_A=$(sed -n "${offset_del_a} {p;q}" data.v1.a.txt)
TEST_UUID_A_SERIAL=$(sed -n "${offset_del_a} {p;q}" data.serial.a.txt)

TEST_UUID_B=$(sed -n "${offset_del_b} {p;q}" data.v1.a.txt)
TEST_UUID_B_SERIAL=$(sed -n "${offset_del_b} {p;q}" data.serial.a.txt)

[ -n "$TEST_UUID_A" ] || error "No UUID selected for tests - please check test data"
[ -n "$TEST_UUID_B" ] || error "No UUID selected for tests - please check test data"

echo "Verifying sudo..."
sudo -u postgres true || error "Initialize sudo for user 'postgres' first"

TEST_TIMESTAMP_A="$(sudo --non-interactive -u postgres psql --port=${PG_PORT} --tuples-only --no-align -c "SELECT uuid_v1_timestamp('${TEST_UUID_A}'::uuid)" ${PG_DATABASE})"
TEST_TIMESTAMP_B="$(sudo --non-interactive -u postgres psql --port=${PG_PORT} --tuples-only --no-align -c "SELECT uuid_v1_timestamp('${TEST_UUID_B}'::uuid)" ${PG_DATABASE})"

[ -n "$TEST_TIMESTAMP_A" ] || error "No timestamp selected for tests - please check test data"
[ -n "$TEST_TIMESTAMP_B" ] || error "No timestamp selected for tests - please check test data"

DATA_DIR=$(pwd)

# apply variables for test...
export TEST_UUID_A TEST_UUID_A_SERIAL TEST_UUID_B TEST_UUID_B_SERIAL TEST_TIMESTAMP_A TEST_TIMESTAMP_B DATA_DIR
envsubst < test-postgresql.sql > $tmpfile

chmod 644 $tmpfile

echo "Preparing database '${PG_DATABASE} ..."
sudo --non-interactive -u postgres psql --port=${PG_PORT} -1 --file=test-postgresql.setup.sql ${PG_DATABASE} || error "Test setup failed"

echo "Executing tests ..."
sudo --non-interactive -u postgres psql --port=${PG_PORT} --echo-all -P pager=off --file=${tmpfile} ${PG_DATABASE} &>$logfile || error "Test execution failed"

cleanup

echo "... all done. Please review the logs at: $logfile"
