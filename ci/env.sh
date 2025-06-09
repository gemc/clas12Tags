#!/usr/bin/env zsh

DetectorDirNotExisting() {
	echo "System directory: $system not existing"
	exit 3
}

log_gemc_info() {
	echo
	echo
	echo "========================================"
	echo "============= log_gemc_info ============"
	echo "========================================"
	echo
	echo "\n > GCard: $gcard"
	echo " > GEMC: $GEMC top level content:\n\n $(ls -l $GEMC/) \n"
	# if GEMC_DATA_DIR different from GEMC, then print it
	if [[ $GEMC_DATA_DIR != $GEMC ]]; then
		echo " > GEMC_DATA_DIR: $GEMC_DATA_DIR top level content:\n\n $(ls -l $GEMC_DATA_DIR/) \n"
	else
		echo " > GEMC_DATA_DIR is the same as GEMC"
	fi

	echo " > gemc: $(which gemc) "
	echo "   Compiled on $(date)"
	echo "   Version:\n$(gemc --version | grep -v Connecting | grep -v RTPC)"
	echo
	echo " Java version:" $(java -version) $(which java)
    echo " JAVA_HOME=${JAVA_HOME:-<unset>}"
    echo " Groovy version: " $(groovy -version)
	echo
	echo "========================================"
	echo "========================================"
	echo "========================================"
	echo
	echo
}

# returns runs to test
runs_for_system() {
	rgm_runs="15016 15043 15108 15165 15178 15318 15356 15434 15458 15534 15566 15637 15643 15671 15732 15733 15734"

	if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
		echo "11 3029"
	elif [[ $system == "dc" || $system == "alert" ]]; then
		echo "11"
	elif [[ $system == "bst" ]]; then
		echo "11 20000"
	elif [[ $system == "htcc" || $system == "ctof" || $system == "cnd" || $system == "magnets" ]]; then
		echo "11 3029 4763"
	elif [[ $system == "micromegas" ]]; then
		echo "11 11620 15016"
	elif [[ $system == "ltcc" ]]; then
		echo "11 3029 4763 6150 11323 15016"
	elif [[ $system == "rich" ]]; then
		echo "11 3029 16043"
	elif [[ $system == "ft" ]]; then
		echo "11 5874 6150 11620 16043 20000"
	elif [[ $system == "beamline" ]]; then
		echo "11 5874 6150 11620 16043 16843 20000 21000"
	elif [[ $system == "magnets" ]]; then
		echo "11 3029 4763"
	elif [[ $system == "targets" ]]; then
		echo "11 3029 4763 6150 6608 11093 $rgm_runs"
	fi
}

variations_for_run_and_system()  {
	if [[ $1 == "11" ]]; then
		echo "default"
	elif [[ $1 == "3029" ]]; then
		echo "rga_spring2018"
	elif [[ $1 == "4763" ]]; then
		echo "rga_fall2018"
	elif [[ $1 == "6608" ]]; then
		echo "rga_spring2019"
	elif [[ $1 == "6150" ]]; then
		echo "rgb_spring2019"
	elif [[ $1 == "11093" ]]; then
		echo "rgb_fall2019"
	elif [[ $1 == "11323" ]]; then
		echo "rgb_winter2020"
	elif [[ $1 == "16043" ]]; then
		echo "rgc_summer2022"
	elif [[ $1 == "16843" ]]; then
		echo "rgc_fall2022"
	elif [[ $1 == "17471" ]]; then
		echo "rgc_winter2023"
	elif [[ $1 == "18305" ]]; then
		echo "rgd_fall2023"
	elif [[ $1 == "20000" ]]; then
		echo "rge_spring2024"
	elif [[ $1 == "11620" ]]; then
		echo "rgf_spring2020"
	elif [[ $1 == "12389" ]]; then
		echo "rgf_summer2020"
	elif [[ $1 == "5674" ]]; then
		echo "rgk_fall2018"
	elif [[ $1 == "5874" ]]; then
		echo "rgk_winter2018"
	elif [[ $1 == "19200" ]]; then
		echo "rgk_winter2023"
	elif [[ $1 == "19300" ]]; then
		echo "rgk_spring2024"
	elif [[ $1 == "21000" ]]; then
		echo "rgl_spring2025"
	elif [[ $1 == "21001" ]]; then
		echo "rgl_spring2025_H2"
	elif [[ $1 == "21002" ]]; then
		echo "rgl_spring2025_D2"
	elif [[ $1 == "21003" ]]; then
		echo "rgl_spring2025_He"
	elif [[ $1 == "21003" ]]; then
		echo "rgl_spring2025"
	elif [[ $1 == "15016" || $1 == "15534" ]]; then
		echo "rgm_fall2021_H"
	elif [[ $1 == "15043" || $1 == "15434" || $1 == "15566" ]]; then
		echo "rgm_fall2021_D"
	elif [[ $1 == "15108" || $1 == "15458" ]]; then
		echo "rgm_fall2021_He"
	elif [[ $1 == "15178" || $1 == "15643" || $1 == "15733" || $1 == "15766" || $1 == "15778" ]]; then
		echo "rgm_fall2021_C"
	elif [[ $1 == "18305" ]]; then
		echo "rgm_fall2021_C"
	elif [[ $1 == "22000" ]]; then
		echo "rgm_fall2021_Cx4"
	elif [[ $1 == "15356" || $1 == "15829" ]]; then
		echo "rgm_fall2021_Ca"
	elif [[ $1 == "15318" || $1 == "15804" ]]; then
		echo "rgm_fall2021_Sn"
	elif [[ $1 == "15807" ]]; then
		echo "rgm_fall2021_Snx4"
	fi
}

# show environment
# export

# if we are in the docker container, we need to load the modules
if [[ -z "${AUTOBUILD}" ]]; then
	echo "\nNot in container"
else
	echo "\nIn docker container."
	if [[ -n "${GITHUB_WORKFLOW}" ]]; then
		echo "GITHUB_WORKFLOW: ${GITHUB_WORKFLOW}"
	fi
	source /etc/profile.d/localSetup.sh
	module switch gemc/dev

	module load hipo
	module load ccdb
	echo

	# recent versions of Git refuse to touch a repository whose on-disk owner
	# doesn’t match the UID that is running the command
	# mark the workspace (and any nested path) as safe
	echo "Marking workspace as safe for Git"
	git config --global --add safe.directory '*'

	export GEMC=$(pwd)
	export GEMC_DATA_DIR=$GEMC
	echo "Setting GEMC and GEMC_DATA_DIR to this directory: $GEMC"
	export PATH=$GEMC/bin:$PATH

fi
