#!/usr/bin/env zsh

# Purpose:
# Runs gemc using the gcards inside 'tests' directory (if existing)
# inside each detectors clas12/ subdirs
# Assumptions: the name 'tests' of the tests directory.


# Local Container run:
# docker run -it --rm add cvmfs mount
# ./ci/tests.sh -d targets -t 5.4


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
	echo "-t: clas12Tags tag to be used"
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hd:t:" option; do
   case $option in
      h)
         Help
         exit
         ;;
      d)
         detector=$OPTARG
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


#DetectorDirNotExisting() {
#	echo "Test Type dir: $example/$testType not existing"
#	Help
#	exit 3
#}
#
#SetsGcardsToRun () {
#	test -d $detector && echo "Detector $detector" || DetectorDirNotExisting
#
#	gcards=`ls $detector/tests/*.gcard`
#
#	echo
#	echo "List of gcards in $detector: $=gcards"
#}



# sets the list of gcards to run
gcards=no
#SetsGcardsToRun


# below to be replaced by module load / run gemc
echo clas12Tag: $clas12Tag, detector: $detector
tdir=/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft/fedora36-gcc12/sim/2.4/clas12Tags/$clas12Tag/experiments/clas12/$detector
echo $tdir content:
ls -l $tdir


#for jc in $=gcards
#do
#	echo "Running gemc for $jc"
#	gemc $jc -showG4ThreadsLog
#	exitCode=$?
#	echo
#	echo exitCode: $exitCode
#	echo
#
#	if [[ $exitCode != 0 ]]; then
#		exit $exitCode
#	fi
#done

echo "Done - Success"