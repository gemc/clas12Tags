#!/usr/bin/env zsh


DetectorDirNotExisting() {
	echo "System directory: $system not existing"
	Help
	exit 3
}

# returns runs to test
runs_for_system() {
	# if system is ec returns 11 and 3029
	if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
		echo "11 3029"
	elif [[ $system == "dc" ]]; then
		echo "11"
	elif [[ $system == "htcc" || $system == "ctof" ]]; then
		echo "11 3029 4763"
	fi
}

variations_for_run_and_system()  {
	if [[ $1 == "11" ]]; then
		echo "default"
	elif [[ $1 == "3029" ]]; then
		if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
			echo "rga_fall2018"
		elif [[ $system == "htcc" || $system == "ctof" ]]; then
			echo "rga_spring2018"
		fi
	elif [[ $1 == "4763" ]]; then
			echo "rga_fall2018"
	fi
}


# Purpose: show clean environment, source local setup if in CI

export
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
#	if [[ -n "${GITHUB_REF}" ]]; then
#		echo "GITHUB_REF: ${GITHUB_REF}"
#		if [[ "${GITHUB_REF}" == "refs/heads/main" || "${GITHUB_REF}" == "refs/heads/new_cad_import" ]]; then
#			module switch gemc/dev
#		fi
#	fi
	export
fi
