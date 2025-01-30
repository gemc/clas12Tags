#!/bin/zsh

cdir=$(pwd)
export COATJAVA=$cdir/coatjava
export PATH=$PATH:$COATJAVA/bin

# CLAS12
cd geometry_source

# if the directory coatjava does not exist, run the script to create it
if [ ! -d "coatjava" ]; then
	./install_coatjava.sh
fi

# Creating new clas12.sqlite DB
$cdir/api/perl/sqlite.py -n clas12.sqlite

all_dets="alert band beamline bst bstShield cnd ctof dc ddvcs ec fluxDets ft ftof ftofShield htcc ltcc magnets micromegas pcal rich rtpc targets uRwell upstream"

# if an argument is given, check that its inside all_dets
if [[ $# -gt 0 ]]; then
	if [[ ! " $all_dets " =~ " $1 " ]]; then
		echo "Error: $1 is not a valid detector"
		exit 1
	fi
	all_dets=$1
fi

# loop over all dets
for dete in $=all_dets; do
	cd $dete
	echo
	echo " > Removing $cdir/experiments/clas12/$dete"
	echo " > And building $dete"
	echo
	rm -rf "$cdir/experiments/clas12/$dete"

	# pre-requirements
	if [ $dete = "ltcc" ]; then
		echo " > Running LTCC mirrors.C"
		root -q -b mirrors.C
	fi

	# main run
	if [[ -f "./$dete.pl" ]]; then
		./"$dete.pl" config.dat
	fi
	copyFilesAndCadDirsTo "$cdir/experiments/clas12/$dete"

	# detectors details

	# target rge-dt
	if [ $dete = "targets" ]; then
		cp -r rge-dt $cdir/experiments/clas12/$dete
	fi

	if [ $dete = "alert" ]; then
		for sdete in He_bag ahdc atof external_shell_nonActif; do
			echo
			echo " > Building ALERT $sdete"
			echo

			cd $sdete
			detep=$sdete
			if [ $sdete = "He_bag" ]; then
				detep="hebag"
			elif [ $sdete = "external_shell_nonActif" ]; then
				detep="alertshell"
			elif [ $sdete = "ahdc" ] || [ $dete = "atof" ]; then
				run-groovy factory.groovy --variation default --runnumber 11
				run-groovy factory.groovy --variation rga_fall2018 --runnumber 11
			fi

			"./$detep.pl" config.dat
			copyFilesAndCadDirsTo "$cdir/experiments/clas12/$dete/$sdete"

			cd ..

		done
	fi

	cd ..
done
