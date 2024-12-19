#!/usr/bin/env zsh

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
	module load hipo
	module load ccdb
	echo
	if [[ -n "${GITHUB_REF}" ]]; then
		if [[ "${GITHUB_REF}" == "refs/heads/dev" || "${GITHUB_REF}" == "refs/heads/new_cad_import" ]]; then
			echo "GITHUB_REF: ${GITHUB_REF}"
			module switch gemc/dev
		fi
	fi
	export
fi
