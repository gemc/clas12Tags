#!/usr/bin/env bash

# setup-java's JDK has its own trust store; retain the JLab CA trusted by the image.
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
if ! "$keytool" -list -keystore "$truststore" -storepass changeit -alias gemc-jlab-ca >/dev/null 2>&1; then
  "$keytool" -importcert -noprompt -trustcacerts -keystore "$truststore" -storepass changeit \
    -alias gemc-jlab-ca -file "$certificate"
fi
