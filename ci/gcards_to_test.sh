#!/usr/bin/env zsh

# Purpose:
# Checkout clas12-config and prepare the matrix of tests to be run

# The remote container (for now) is based on fedora 36, so cvmfs action is not available,
# see https://github.com/cvmfs-contrib/github-action-cvmfs (only ubuntu supported)
# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/base:fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/gcards_to_test.sh

validTags=(4.4.2 5.2 5.3)
[[ -d  clas12-config ]] && echo clas12-config exist || git clone https://github.com/JeffersonLab/clas12-config

for clas12Tag in $validTags; do
  # if $clas12Tags is not dev, gcards are the files in clas12-config/gemc/$clas12Tags/config,
  # otherwise they are in config
  if [[ $clas12Tag != "dev" ]]; then
    gcards=(${gcards[@]} $(ls clas12-config/gemc/$clas12Tag/*.gcard | awk -F\/ '{print $3"/"$4}' ))
  else
    gcards=(${gcards[@]} $(ls config/*.gcard | sed s/config/dev/g ))
  fi
done


lastg=${gcards[${#gcards[@]}]}

echo "{\"include\":["
for jc in $=gcards; do
  [[ $jc ==  $lastg ]] && echo "{\"gcard\": \"$jc\"}" || echo "{\"gcard\": \"$jc\"},"
done
echo "]}"
