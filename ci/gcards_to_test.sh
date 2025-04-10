#!/usr/bin/env zsh

# Purpose:
# Checkout clas12-config and prepare the matrix of tests to be run

# The remote container (for now) is based on fedora 36, so cvmfs action is not available,
# see https://github.com/cvmfs-contrib/github-action-cvmfs (only ubuntu supported)
# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/gcards_to_test.sh

[[ -d clas12-config  ]] && echo clas12-config exist || git clone -b dev https://github.com/JeffersonLab/clas12-config

# gcards is an array containing the list of files in clas12-config/gemc/dev
gcards=($(ls clas12-config/gemc/dev | grep -v sqlite))

# lastg is last element of the array
lastg=${gcards[-1]}

echo "{\"include\":["
for jc in $=gcards; do
	[[ $jc == $lastg ]] && echo "{\"gcard\": \"$jc\"}" || echo "{\"gcard\": \"$jc\"},"
done
echo "]}"
