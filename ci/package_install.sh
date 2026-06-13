#!/usr/bin/env bash
set -euo pipefail

# Build a relocatable clas12Tags install tarball from an existing Meson install prefix.
#
# Usage:
#   bash ci/package_install.sh [INSTALL_PREFIX] [OUTPUT_DIR] [PACKAGE_NAME]

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

if [[ $# -gt 3 ]]; then
	echo "Usage: $0 [INSTALL_PREFIX] [OUTPUT_DIR] [PACKAGE_NAME]" >&2
	exit 2
fi

install_prefix="${1:-${SIM_HOME:?SIM_HOME not set}/clas12Tags/dev}"
output_dir="${2:-${repo_root}/dist}"
geant4_version="${GEANT4_VERSION:-11.4.1}"
arch="$(uname -m)"
case "${arch}" in
	x86_64) arch=amd64 ;;
	aarch64 | arm64) arch=arm64 ;;
esac

clas12tags_version="${CLAS12TAGS_PACKAGE_VERSION:-dev}"
package_name="${3:-clas12Tags-${clas12tags_version}-geant4-${geant4_version}-linux-${arch}}"

if [[ ! -d "${install_prefix}" ]]; then
	echo "Install prefix does not exist: ${install_prefix}" >&2
	exit 1
fi

mkdir -p "${output_dir}"
stage="$(mktemp -d)"
trap 'rm -rf "${stage}"' EXIT

package_root="${stage}/${package_name}"
cp -a "${install_prefix}" "${package_root}"

archive_name_from_data_dir() {
	local directory="$1"
	local prefix version

	if [[ "${directory}" =~ ^(G4)?([A-Za-z]+)([0-9].*)$ ]]; then
		prefix="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
		version="${BASH_REMATCH[3]}"
	else
		echo "Cannot derive Geant4 dataset archive name from directory: ${directory}" >&2
		return 1
	fi

	if [[ "${prefix}" == G4* ]]; then
		printf '%s.%s.tar.gz\n' "${prefix}" "${version}"
	else
		printf 'G4%s.%s.tar.gz\n' "${prefix}" "${version}"
	fi
}

geant4_dataset_records=()

if command -v geant4-config >/dev/null 2>&1; then
	eval "$(geant4-config --sh)"
fi

while IFS='=' read -r env_name env_path; do
	[[ -n "${env_name}" && -n "${env_path}" ]] || continue
	if [[ ! -d "${env_path}" ]]; then
		echo "Geant4 data environment variable ${env_name} points to a missing directory: ${env_path}" >&2
		exit 1
	fi
	data_dir_name="$(basename "${env_path}")"
	archive_name="$(archive_name_from_data_dir "${data_dir_name}")"
	geant4_dataset_records+=("${env_name}|${archive_name}|${data_dir_name}")
done < <(env | LC_ALL=C sort | grep -E '^G4[A-Z0-9_]*DATA=' || true)

if (( ${#geant4_dataset_records[@]} == 0 )); then
	echo "No Geant4 data environment variables were found." >&2
	echo "Load the Geant4 environment before running $0." >&2
	exit 1
fi

cat >"${package_root}/clas12tags.env" <<'EOF'
# Source this file after unpacking the clas12Tags tarball.
#
# Geant4 data directories are expected under ${CLAS12TAGS_HOME}/geant4-data.
# Run ${CLAS12TAGS_HOME}/install_geant4_data.sh to download and unpack them.

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
	CLAS12TAGS_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
	CLAS12TAGS_ENV_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
	CLAS12TAGS_ENV_DIR="$(pwd)"
fi

export CLAS12TAGS_HOME="${CLAS12TAGS_HOME:-${CLAS12TAGS_ENV_DIR}}"
export GEMC="${GEMC:-${CLAS12TAGS_HOME}}"
export GEMC_DATA_DIR="${GEMC_DATA_DIR:-${CLAS12TAGS_HOME}}"
export PATH="${CLAS12TAGS_HOME}/bin:${PATH}"
export PYTHONPATH="${CLAS12TAGS_HOME}/api:${PYTHONPATH:-}"
export PERL5LIB="${CLAS12TAGS_HOME}/api/perl:${PERL5LIB:-}"
export PKG_CONFIG_PATH="${CLAS12TAGS_HOME}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
if [ -d "${CLAS12TAGS_HOME}/lib" ]; then
	export LD_LIBRARY_PATH="${CLAS12TAGS_HOME}/lib:${LD_LIBRARY_PATH:-}"
fi

export CLAS12TAGS_GEANT4_DATA_DIR="${CLAS12TAGS_HOME}/geant4-data"

clas12tags_geant4_datasets=(
EOF

for record in "${geant4_dataset_records[@]}"; do
	env_name="${record%%|*}"
	rest="${record#*|}"
	data_dir_name="${rest#*|}"
	printf '  "%s|%s"\n' "${env_name}" "${data_dir_name}" >>"${package_root}/clas12tags.env"
done

cat >>"${package_root}/clas12tags.env" <<'EOF'
)

for clas12tags_dataset in "${clas12tags_geant4_datasets[@]}"; do
	clas12tags_env_name="${clas12tags_dataset%%|*}"
	clas12tags_data_dir="${clas12tags_dataset#*|}"
	export "${clas12tags_env_name}=${CLAS12TAGS_GEANT4_DATA_DIR}/${clas12tags_data_dir}"
done

clas12tags_missing_data=()
for clas12tags_dataset in "${clas12tags_geant4_datasets[@]}"; do
	clas12tags_env_name="${clas12tags_dataset%%|*}"
	clas12tags_data_dir="${clas12tags_dataset#*|}"
	clas12tags_data_path="${CLAS12TAGS_GEANT4_DATA_DIR}/${clas12tags_data_dir}"
	if [[ ! -d "${clas12tags_data_path}" ]]; then
		clas12tags_missing_data+=("${clas12tags_env_name}: ${clas12tags_data_path}")
	fi
done

if (( ${#clas12tags_missing_data[@]} > 0 )); then
	echo "clas12Tags Geant4 data check failed. Missing required data directories:" >&2
	printf '  %s\n' "${clas12tags_missing_data[@]}" >&2
	echo "Run: ${CLAS12TAGS_HOME}/install_geant4_data.sh" >&2
	return 1 2>/dev/null || exit 1
fi

unset clas12tags_data_dir clas12tags_data_path clas12tags_dataset clas12tags_env_name
unset clas12tags_geant4_datasets clas12tags_missing_data
EOF

cat >"${package_root}/install_geant4_data.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data_dir="${script_dir}/geant4-data"
base_url="${GEANT4_DATA_BASE_URL:-https://cern.ch/geant4-data/datasets}"

datasets=(
EOF

for record in "${geant4_dataset_records[@]}"; do
	env_name="${record%%|*}"
	rest="${record#*|}"
	archive_name="${rest%%|*}"
	data_dir_name="${rest#*|}"
	printf '  "%s|%s|%s"\n' "${env_name}" "${archive_name}" "${data_dir_name}" \
		>>"${package_root}/install_geant4_data.sh"
done

cat >>"${package_root}/install_geant4_data.sh" <<'EOF'
)

download() {
	local url="$1"
	local output="$2"
	if command -v curl >/dev/null 2>&1; then
		curl -fL --retry 3 -o "${output}" "${url}"
	elif command -v wget >/dev/null 2>&1; then
		wget -O "${output}" "${url}"
	else
		echo "Neither curl nor wget is available." >&2
		return 1
	fi
}

mkdir -p "${data_dir}"

for item in "${datasets[@]}"; do
	env_name="${item%%|*}"
	rest="${item#*|}"
	archive="${rest%%|*}"
	directory="${rest#*|}"
	target="${data_dir}/${directory}"

	if [[ -d "${target}" ]]; then
		echo "Found ${env_name}: ${directory}"
		continue
	fi

	tmp="$(mktemp -d)"
	trap 'rm -rf "${tmp}"' EXIT
	echo "Downloading ${env_name}: ${directory}"
	download "${base_url}/${archive}" "${tmp}/${archive}"
	tar -xzf "${tmp}/${archive}" -C "${data_dir}"
	rm -rf "${tmp}"
	trap - EXIT

	if [[ ! -d "${target}" ]]; then
		echo "Expected directory was not created: ${target}" >&2
		exit 1
	fi
done

echo "Geant4 data installed in ${data_dir}"
EOF
chmod +x "${package_root}/install_geant4_data.sh"

cat >"${package_root}/INSTALL_TARBALL.md" <<'EOF'
# clas12Tags tarball installation

This archive contains the clas12Tags GEMC install tree.

```bash
./install_geant4_data.sh
source ./clas12tags.env
gemc -v
```
EOF

tarball="${output_dir}/${package_name}.tar.gz"
tar -C "${stage}" -czf "${tarball}" "${package_name}"
echo "${tarball}"
