#!/usr/bin/env bash

# Apply the same policy to every Maven call, including bare calls in older Coatjava tags.
# Maven before 3.9 does not read MAVEN_ARGS, so pass these options explicitly.
set -euo pipefail

# Suppress cookie-parser noise while retaining HTTP transfer and dependency diagnostics.
cookie_logger=org.apache.http.client.protocol.ResponseProcessCookies
export MAVEN_OPTS="${MAVEN_OPTS:-} -Dorg.slf4j.simpleLogger.log.$cookie_logger=error"

exec "${COATJAVA_MAVEN_EXECUTABLE:?Original Maven executable must be configured}" \
  "${COATJAVA_SNAPSHOT_POLICY:---no-snapshot-updates}" \
  --batch-mode --no-transfer-progress \
  -Dmaven.artifact.threads=1 -Daether.connector.http.retryHandler.count=5 "$@"
