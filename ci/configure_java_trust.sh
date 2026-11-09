#!/usr/bin/env bash

# setup-java's JDK has its own trust store; include the CAs needed by JLab repositories.
set -euo pipefail

: "${JAVA_HOME:?JAVA_HOME must point to the JDK used for the Coatjava build}"
certificate=${1:-}
if [[ -z "$certificate" ]]; then
  for candidate in \
    /etc/pki/ca-trust/source/anchors/JLabCA.crt \
    /usr/local/share/ca-certificates/JLabCA.crt \
    /etc/ca-certificates/trust-source/anchors/JLabCA.crt; do
    if [[ -r "$candidate" ]]; then
      certificate=$candidate
      break
    fi
  done
fi
if [[ -z "$certificate" || ! -r "$certificate" ]]; then
  echo "JLab CA certificate not found; use a GEMC image containing the trusted JLab CA." >&2
  exit 1
fi

keytool="$JAVA_HOME/bin/keytool"
truststore="$JAVA_HOME/lib/security/cacerts"
if [[ ! -r "$truststore" ]]; then
  echo "Selected JDK trust store not found: $truststore" >&2
  exit 1
fi
import_ca() {
  local alias=$1 certificate=$2
  if ! "$keytool" -list -keystore "$truststore" -storepass changeit -alias "$alias" >/dev/null 2>&1; then
    "$keytool" -importcert -noprompt -trustcacerts -keystore "$truststore" -storepass changeit \
      -alias "$alias" -file "$certificate"
  fi
}

import_ca gemc-jlab-ca "$certificate"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
import_ca gemc-emsign-root-ca-g1 "$script_dir/certificates/emsign-root-ca-g1.pem"
