#!/usr/bin/env zsh

# Purpose:
# Runs gemc using the gcards inside 'tests' directory (if existing)
# inside each detectors clas12/ subdirs
# Assumptions: the name 'tests' of the tests directory.


# The remote container (for now) is based on fedora 36, so cvmfs action is not available,
# see https://github.com/cvmfs-contrib/github-action-cvmfs (only ubuntu supported)
# Mounting cvmfs container run:
# docker run -it --rm --platform linux/amd64  -v/cvmfs:/cvmfs jeffersonlab/cvmfs:fedora36 sh
# Full image container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:4.4.2-5.1-5.2-5.3-fedora36-cvmfs sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/experiments_test.sh  -t 5.3

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
	echo "Syntax: tests.sh [-h|t]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-t: clas12Tags tag to be used"
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":ht:" option; do
   case $option in
      h)
         Help
         exit
         ;;
      t)
         clas12Tag=$OPTARG
         ;;
       \?) # Invalid option
         echo "Error: Invalid option"
         exit 1
         ;;
   esac
done


ExperimentNotExisting() {
  gcard=$1
	echo "Gcard: $gcard not existing"
	Help
	exit 3
}


git clone https://github.com/JeffersonLab/clas12-config
echo "\nRunning tests with clas12Tags $clas12Tag\n"

module switch gemc/$clas12Tag

for jc in $=gcards
do
  if [[ ! -f "$jc" ]]; then
    ExperimentNotExisting $jc
  fi

	echo "Running gemc $clas12Tags for $jc"
	gemc -BEAM_P="e-, 4*GeV, 20*deg, 25*deg" -SPREAD_P="0*GeV, 10*deg, 180*deg" -USE_GUI=0 -N=100 -PRINT_EVENT=10 $jc
	exitCode=$?
	echo
	echo exitCode: $exitCode
	echo

	if [[ $exitCode != 0 ]]; then
		exit $exitCode
	fi
done

echo "Done - Success"