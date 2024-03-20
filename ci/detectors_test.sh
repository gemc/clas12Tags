#!/usr/bin/env zsh

# Purpose:
# Runs gemc using the gcards inside 'tests' directory (if existing)
# inside each detectors clas12/ subdirs
# Assumptions: the name 'tests' of the tests directory.


# The remote container (for now) is based on fedora 36, so cvmfs action is not available
# see https://github.com/cvmfs-contrib/github-action-cvmfs (only ubuntu supported)
# Full image container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-g4v10.7.4-fedora36-cvmfs sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/detectors_test.sh -d targets

# if we are in the docker container, we need to load the modules
if [[ -z "${DISTTAG}" ]]; then
    echo "\nNot in container"
else
    echo "\nIn container: ${DISTTAG}"
    source  /app/localSetup.sh
fi

Help()
{
	# Display Help
	echo
	echo "Syntax: tests.sh [-h|d]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-d: build geometry and runs detector gcards in subdir 'tests' "
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hd:" option; do
   case $option in
      h)
         Help
         exit
         ;;
      d)
         detector="experiments/clas12/$OPTARG"
         ;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit 1
         ;;
   esac
done


DetectorDirNotExisting() {
	echo "Detector dir: $detector not existing"
	Help
	exit 3
}


# the list of detectors in the yaml file only includes
# detectors with tests directory
SetsGcardsToRun () {
	test -d $detector && echo "Detector $detector" || DetectorDirNotExisting

	gcards=`ls $detector/tests/*.gcard`

	echo
	echo "List of gcards in $detector: $=gcards"
}

SetsGcardsToRun


# below to be replaced by module load / run gemc
echo testing detector: $detector

./ci/build_gemc.sh

for jc in $=gcards
do
	echo "Running gemc test for $detector, gcard: $jc"
	gemc $jc -N=100 -USE_GUI=0 -PRINT_EVENT=10
	exitCode=$?
	echo
	echo exitCode: $exitCode
	echo

	if [[ $exitCode != 0 ]]; then
		exit $exitCode
	fi
done

echo "Done - Success"