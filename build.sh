#! /bin/bash
set -euxo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TARGET="${1:-${SCRIPT_DIR}/target}"

# Build the repos locally
(
  cd ${TARGET}/apicurio-registry && \
  mvn clean install -DskipTests
) &
PID_JOB1=$!
(
  cd ${TARGET}/apicurio-registry && \
  mvn clean install -DskipTests
) &
PID_JOB2=$!
(
  cd ${TARGET}/apicurio-registry/ui && \
  ./init-dev.sh && \
  yarn install
) &
PID_JOB3=$!

wait $PID_JOB1 $PID_JOB2 $PID_JOB3
