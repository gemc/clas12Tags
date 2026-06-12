#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run --rm -it  ghcr.io/gemc/g4install:11.4.0-fedora-40  bash -li
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

function usage {
	cat <<'EOF'
Usage: ./ci/build.sh [--install-dir DIR]

Options:
  -i, --install-dir DIR  Install prefix for local builds. Defaults to $repo_root/install.
  -h, --help             Show this help message.
EOF
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
local_install_dir=

while [[ $# -gt 0 ]]; do
	case "$1" in
		-i|--install-dir)
			if [[ $# -lt 2 || -z "$2" ]]; then
				echo "Missing value for $1" >&2
				usage
				exit 2
			fi
			local_install_dir=$2
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage
			exit 2
			;;
	esac
done

if [[ -z "${AUTOBUILD}" && -n "$local_install_dir" ]]; then
	export GEMC=${local_install_dir:a}
fi

source ci/env.sh

function compile_gemc {

	local install_dir="${GEMC:?GEMC not set}"
	local meson_option=(
		"--native-file=core.ini"
		"-Dprefix=${install_dir}"
		"-Dpkg_config_path=${PKG_CONFIG_PATH}:${install_dir}/lib/pkgconfig"
		"-Dbuildtype=release"
	)

	echo " > Geant-config: $(which geant4-config) : $(geant4-config --version)" | tee $setup_log
	echo
	echo " > Meson Setup Options: $meson_option"
	echo " > Using $jobs cores"
	echo

	cd source
	echo
	echo " > Running meson setup build $=meson_option" | tee -a $setup_log
	meson setup build $=meson_option >>$setup_log 2>&1
	if [ $? -ne 0 ]; then
		fail_with_log " > Meson Configure failed. Log: " "$setup_log"
	else
		echo " > Meson Configure Successful"
		echo
	fi

	echo " > Running meson compile -C build -v -j $jobs " | tee -a $compile_log
	meson compile -C build -v -j $jobs >>$compile_log 2>&1
	if [ $? -ne 0 ]; then
		fail_with_log " > Meson Compile failed. Log: " "$compile_log"
	else
		echo " > Meson Compile Successful"
		echo
	fi

	echo " > Running meson install -C build " | tee -a $install_log
	meson install -C build >>$install_log 2>&1
	if [ $? -ne 0 ]; then
		fail_with_log " > Meson Install failed. Log: " "$install_log"
	else
		echo " > Meson Install Successful"
		echo
	fi

	cd ..
}

function test_gemc {

	cd source

	local test_options=(
		-C build
		--suite clas12
		--print-errorlogs
		-j 1
		--no-rebuild
		--num-processes 1
		-v
	)
	: > "$test_log"
	if ! retry_command "meson test" "$test_log" meson test "${test_options[@]}"; then
		fail_with_log " > Meson Tests failed. Log: " "$test_log"
	else
		echo " > Meson Tests Successful"
		echo
	fi

	echo "   - Successful: $(grep 'Ok:' "$test_log" | awk '{sum += $2} END {print sum + 0}')" | tee -a "$test_log"
	echo "   - Failures:   $(grep 'Fail:' "$test_log" |
		awk '{sum += $2} END {print sum + 0}')" | tee -a "$test_log"
	echo " > Complete test log: $test_log"

	cd ..
}

compile_gemc

test_gemc

# log info
show_gemc_installation
log_java_info


echo
echo "Copying executable, experiments, and api for artifact retrieval"
mkdir -p $ARTIFACT_DIR/bin || fail_with_log "Creating artifact bin directory failed. Log:" "$install_log"
cp $GEMC/bin/gemc $ARTIFACT_DIR/bin || fail_with_log "Copying GEMC executable failed. Log:" "$install_log"
cp -r experiments $ARTIFACT_DIR || fail_with_log "Copying experiments failed. Log:" "$geo_log"
cp -r api $ARTIFACT_DIR || fail_with_log "Copying API failed. Log:" "$install_log"
echo
echo "Content of artifacts dir $ARTIFACT_DIR:"
ls -lrt $ARTIFACT_DIR || fail_with_log "Listing artifact directory failed. Log:" "$install_log"
