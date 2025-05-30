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
	echo "Syntax: gcard_run_test.sh [-h|g]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-d: detector gcards to be tested"
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
			detector="$OPTARG"
			;;
		\?) # Invalid option
			echo "Error: Invalid option"
			exit 1
			;;
	esac
done


# set gcards to the list of files in the directory geometry_source/$detector with extension .gcard
cd geometry_source/$detector || {
	echo "Directory geometry_source/$detector does not exist"
	exit 2
}

echo " > Detector: $detector\n"
echo " > Directory: $(pwd)\n"

gcards=$(ls *.gcard)

for gcard in $=gcards; do
	echo " > Running gcard: $gcard"

	if [[ ! -f "$gcard" ]]; then
		echo "Gcard: $gcard not existing"
		exit 3
	fi
	echo "Running gemc with options:  -BEAM_P=\"e-, 4*GeV, 60*deg, 25*deg\" -SPREAD_P=\"0*GeV, 40*deg, 180*deg\" -USE_GUI=0 -N=1000 -PRINT_EVENT=10 $gcard"
	gemc -BEAM_P="e-, 4*GeV, 60*deg, 25*deg" -SPREAD_P="0*GeV, 40*deg, 180*deg" -USE_GUI=0 -N=1000 -PRINT_EVENT=10 $gcard
	exitCode=$?

	if [[ $exitCode != 0 ]]; then
		echo exiting with gemc exitCode: $exitCode
		exit $exitCode
	fi
done

echo "Done - Success!"
