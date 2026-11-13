#!/usr/bin/env bash

# Make the selected JDK trust the certificate authorities needed by Maven's JLab repositories.
#
# The GEMC image already has a JLab CA certificate in its operating-system trust store, used by
# tools such as curl. However, actions/setup-java installs a JDK with its own lib/security/cacerts;
# that JDK does not automatically inherit the image's OS trust configuration. Maven uses Java's
# trust store, so it can fail with "PKIX path building failed" even when curl trusts the same server.
# The Coatjava installer calls this helper in CI, with JAVA_HOME pointing to the selected JDK.
#
# This script downloads nothing. Its two certificate inputs are:
# - JLabCA.crt: copied into the GEMC image during its build from g4install/ci/assets/JLabCA.crt.
#   The image-build source identifies https://pki.jlab.org/JLabCA.crt as the source for manual updates.
#   Find the image's copy in the OS-specific directories below, or use the optional first argument.
#   Fail if it is missing rather than downloading a replacement during the build.
# - emSign Root CA - G1: checked into this repository as ci/certificates/emsign-root-ca-g1.pem,
#   originally extracted from a trusted OS CA bundle. It validates the public InCommon chain seen
#   at code.jlab.org; this chain uses a different root from the image's private JLab CA.
#
# Import both into the selected JDK while retaining its existing trusted CAs. Skip each import if
# its gemc-* alias already exists, so repeated calls are harmless. A JDK that already trusts both
# authorities would not need these extra imports. Certificate and hostname verification stay enabled.
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
