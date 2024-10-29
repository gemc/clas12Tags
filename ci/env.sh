#!/usr/bin/env zsh

# Purpose: show clean environment, source local setup if in CI

export
# if we are in the docker container, we need to load the modules
if [[ -z "${AUTOBUILD}" ]]; then
	echo  "\nNot in container"
else
	echo  "\nIn docker container."
	if [[ -n "${GITHUB_WORKFLOW}" ]]; then
		echo "GITHUB_WORKFLOW: ${GITHUB_WORKFLOW}"
	fi
	source  /etc/profile.d/localSetup.sh
	echo
	export
fi

