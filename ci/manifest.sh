#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ci/manifest.sh SUMMARY_FILE IMAGE TAG [DOWNLOADED_LOGS_DIR]
#
# - SUMMARY_FILE: path to markdown summary file
# - IMAGE: e.g. ghcr.io/gemc/src
# - TAG:   e.g. dev-11.4.0-ubuntu-24.04
# - DOWNLOADED_LOGS_DIR (optional): contains logs-${TAG}-*.tgz

summary_file="${1:?missing SUMMARY_FILE}"
image="${2:?missing IMAGE}"
tag="${3:?missing TAG}"
dl_dir="${4:-}"

{
  printf '## `%s:%s`\n' "${image}" "${tag}"
  printf '\n'
  printf 'Includes:\n'
  if docker buildx imagetools inspect "${image}:${tag}-amd64" >/dev/null 2>&1; then
    printf -- '- amd64\n'
  fi
  if docker buildx imagetools inspect "${image}:${tag}-arm64" >/dev/null 2>&1; then
    printf -- '- arm64\n'
  else
    printf -- '- no arm64. Run with --platform=linux/amd64 in arm64 CPUs. On MacOs you may need to use Rosetta for correct terminal emulation.\n'
  fi
  printf '\n'
  printf '### Pull\n'
  printf '```bash\n'
  printf 'docker pull %s:%s\n' "${image}" "${tag}"
  printf '```\n'
  printf '\n'
  printf '### Run in batch mode\n'
  printf '```bash\n'
  printf 'docker run --rm -it %s:%s bash -l\n' "${image}" "${tag}"
  printf '```\n'
  printf '\n'
  printf '### Run with VNC/noVNC\n'
  printf '_VNC → localhost:5900 (password: change-me)_\n'
  printf '_noVNC → http://localhost:6080/vnc.html (password: change-me)_\n'
  printf '```bash\n'
  printf 'docker run --rm -it $VPORTS $VNC_BIND $VNC_PASS $GEO_FLAGS %s:%s\n' "${image}" "${tag}"
  printf '```\n'
  printf '\n'
} >> "${summary_file}"

