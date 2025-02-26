#!/usr/bin/env zsh

DetectorDirNotExisting() {
	echo "System directory: $system not existing"
	exit 3
}

# returns runs to test
runs_for_system() {
	if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
		echo "11 3029"
	elif [[ $system == "dc" ]]; then
		echo "11"
	elif [[ $system == "bst" ]]; then
		echo "11 20000"
	elif [[ $system == "htcc" || $system == "ctof" || $system == "cnd" ]]; then
		echo "11 3029 4763"
	elif [[ $system == "micromegas" ]]; then
		echo "3029 11620 15016"
	elif [[ $system == "ltcc" ]]; then
		echo "11 3029 4763 6150 11323 15016"
	elif [[ $system == "rich" ]]; then
		echo "11 3029 16043"
	elif [[ $system == "ft" ]]; then
		echo "11 5874 6150 11620 16043 20000"
	elif [[ $system == "beamline" ]]; then
		echo "11 5874 6150 11620 16043 16843 20000"
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
	elif [[ $1 == "15016" ]]; then
		echo "rgm_winter2021"
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
fi
