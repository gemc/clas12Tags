#!/usr/bin/env zsh

# Purpose: runs gemc using all the gcards in clas12-config dev branch

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/gcard_run_test.sh

source ci/env.sh

Help() {
	# Display Help
	echo
	echo "Syntax: gcard_run_test.sh [-h|g|l]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-g: gcard to be used"
	echo "-l: lund file base name"
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hg:l:" option; do
	case $option in
		h)
			Help
			exit
			;;
		g)
			gcard="clas12-config/gemc/dev/$OPTARG"
			;;
		l)
			lund="ci/generated_events/$OPTARG"
			;;		\?) # Invalid option
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

echo "Running on branch: $BRANCH_NAME"

[[ -d clas12-config ]] && echo clas12-config exist || git clone -b dev https://github.com/JeffersonLab/clas12-config
echo " > Gcard: $gcard\n"

if [[ ! -f "$gcard" ]]; then
	ExperimentNotExisting $gcard
fi

nevents=200
lund_file=$lund"_tracks.dat"
echo "Generating file events.dat from lund file: $lund_file"
./ci/generated_events/randomize_particles.py --nevents $nevents -o events.dat --theta-min 7 --theta-max 120 --seed 123 $lund_file

echo "Running gemc with options:  -INPUT_GEN_FILE=\"lund, events.dat\" -USE_GUI=0 -N=$nevents -PRINT_EVENT=10 -GEN_VERBOSITY=10 $gcard"
gemc -INPUT_GEN_FILE="lund, events.dat"  -USE_GUI=0 -N=$nevents -PRINT_EVENT=10 -GEN_VERBOSITY=10 $gcard > gemc.log
exitCode=$?

if [[ $exitCode != 0 ]]; then
	echo exiting with gemc exitCode: $exitCode
	exit $exitCode
fi

mkdir -p /root/logs
log_file=/root/logs/"$lund"_tracks.log
touch $log_file

grep "Events only time:" gemc.log | cut -d':' -f3 > $log_file

echo
cat $log_file
echo
