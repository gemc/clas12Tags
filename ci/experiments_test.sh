#!/usr/bin/env zsh

# Purpose: runs gemc using all the gcards in clas12-config dev branch

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/experiments_test.sh

source ci/env.sh

Help() {
	# Display Help
	echo
	echo "Syntax: tests.sh [-h|g]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-g: gcard to be used"
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hg:" option; do
	case $option in
		h)
			Help
			exit
			;;
		g)
			gcard="clas12-config/gemc/dev/$OPTARG"
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

./ci/build_gemc.sh

[[ -d clas12-config ]] && echo clas12-config exist || git clone -b dev https://github.com/JeffersonLab/clas12-config
echo "\nGcard: $gcard\n"

if [[ ! -f "$gcard" ]]; then
	ExperimentNotExisting $gcard
fi

echo "\nGEMC executable: $(which gemc)\n\n"
echo "Running gemc with $gcard"
gemc -BEAM_P="e-, 4*GeV, 20*deg, 25*deg" -SPREAD_P="0*GeV, 10*deg, 180*deg" -USE_GUI=0 -N=1000 -PRINT_EVENT=10 $gcard
exitCode=$?

if [[ $exitCode != 0 ]]; then
	echo exiting with gemc exitCode: $exitCode
	exit $exitCode
fi

echo "Done - Success!"
