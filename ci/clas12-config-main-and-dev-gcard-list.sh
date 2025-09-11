#!/usr/bin/env zsh

# Purpose:
# Checkout clas12-config dev and main, select gcards in common, and prepare the matrix of tests to be run

# The remote container (for now) is based on fedora 36, so cvmfs action is not available,
# see https://github.com/cvmfs-contrib/github-action-cvmfs (only ubuntu supported)
# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/gcards_devconfig_list.sh

[[ -d clas12-config-dev  ]]  && echo clas12-config-dev exist  || git clone -b dev https://github.com/JeffersonLab/clas12-config clas12-config-dev
[[ -d clas12-config-main  ]] && echo clas12-config-main exist || git clone -b main https://github.com/JeffersonLab/clas12-config clas12-config-main

# gcards is an array containing the list of files in clas12-config/gemc/dev
gcards_dev=($(ls clas12-config-dev/gemc/dev | grep -v sqlite))
gcards_main=($(ls clas12-config-main/gemc/dev | grep -v sqlite))

# creating list of gcards in common
gcards=()
for gcard in $=gcards_dev; do
	if [[ " ${gcards_main[@]} " =~ " ${gcard} " ]]; then
		gcards+=($gcard)
	fi
done

# lastg is last element of the array
lastg=${gcards[-1]}

echo "{\"include\":["
for jc in $=gcards; do
	[[ $jc == $lastg ]] && echo "{\"gcard\": \"$jc\"}" || echo "{\"gcard\": \"$jc\"},"
done
echo "]}"
