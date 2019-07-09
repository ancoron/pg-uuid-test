#!/bin/bash

PG_PORT=${PG_PORT:-5432}
PG_DATABASE=${PG_DATABASE:-test}

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

if [ -f data.serial.a.txt ]; then
    echo "Reusing existing test data..."
else
    [ -d "$path_generator" ] || error "Path to Maven project clone required from: https://github.com/ancoron/java-uuid-serial"

    mvn -f "$path_generator/pom.xml" clean install -Duuids=100000000 -Dinterval_days=365 -Duuid.historic=true -Duuid.skip.v1=false -Dnodes=9 || error "Unable to generate UUID data"

    echo "Preparing test data..."
    sed '80000000 {q}' "$path_generator/target/uuids.v1.historic.txt" > data.v1.a.txt
    sed -n '80000001,$p' "$path_generator/target/uuids.v1.historic.txt" > data.v1.b.txt
    sed '80000000 {q}' "$path_generator/target/uuids.serial.historic.txt" > data.serial.a.txt
    sed -n '80000001,$p' "$path_generator/target/uuids.serial.historic.txt" > data.serial.b.txt

    echo "...remove unnecessary files..."
    mvn -f "$path_generator/pom.xml" clean
fi

TEST_UUID_A=$(sed -n '20000001 {p;q}' data.v1.a.txt)
TEST_UUID_A_SERIAL=$(sed -n '20000001 {p;q}' data.serial.a.txt)

TEST_UUID_B=$(sed -n '40000001 {p;q}' data.v1.a.txt)
TEST_UUID_B_SERIAL=$(sed -n '40000001 {p;q}' data.serial.a.txt)

echo "Verifying sudo..."
sudo -u postgres true || error "Initialize sudo for user 'postgres' first"

TEST_TIMESTAMP_A="$(sudo --non-interactive -u postgres psql --port=${PG_PORT} --tuples-only --no-align -c "SELECT uuid_v1_timestamp('${TEST_UUID_A}')" ${PG_DATABASE})"
TEST_TIMESTAMP_B="$(sudo --non-interactive -u postgres psql --port=${PG_PORT} --tuples-only --no-align -c "SELECT uuid_v1_timestamp('${TEST_UUID_B}')" ${PG_DATABASE})"

DATA_DIR=$(pwd)

# apply variables for test...
export TEST_UUID_A TEST_UUID_A_SERIAL TEST_UUID_B TEST_UUID_B_SERIAL TEST_TIMESTAMP_A TEST_TIMESTAMP_B DATA_DIR
envsubst < test-postgresql.sql > $tmpfile

chmod 644 $tmpfile

sudo --non-interactive -u postgres psql --port=${PG_PORT} -1 --file=test-postgresql.setup.sql ${PG_DATABASE} || error "Test setup failed"

sudo --non-interactive -u postgres psql --port=${PG_PORT} --echo-all -P pager=off --file=${tmpfile} ${PG_DATABASE} &>$logfile || error "Test execution failed"

cleanup
