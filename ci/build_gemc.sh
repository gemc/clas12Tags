#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

source ci/env.sh

function compile_gemc {
	cd source
	# getting number of available CPUS
	copt=" -j"$(getconf _NPROCESSORS_ONLN)" OPT=1"
	echo
	echo Compiling GEMC with options: "$copt"
	scons SHOWENV=1 SHOWBUILD=1 $copt
	# checking existence of executable
	ls gemc
	if [ $? -ne 0 ]; then
		echo gemc executable not found
		exit 1
	fi
	cd ..
	echo "Copying gemc to $GEMC/bin for CI"
	cp gemc $GEMC/bin
}

function create_geo_dbs {
	./create_geometry.sh
	echo "Copying experiments ASCII DB and sqlite file to $GEMC for CI"
	cp -r experiments clas12.sqlite $GEMC
}

compile_gemc
create_geo_dbs

echo
echo "Content of $GEMC dir:"
ls -lrt $GEMC
echo
echo "Content of sync dir /cvmfs/oasis.opensciencegrid.org/jlab/geant4"
ls -lrt -R /cvmfs/oasis.opensciencegrid.org/jlab/geant4

# copying executable, api and sqlite database for artifact retrieval
# the experiment dir is synced with the bin/cron_gemc_artifact_install_jlab.sh
mkdir -p /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp source/gemc /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp -r api /cvmfs/oasis.opensciencegrid.org/jlab/geant4
cp clas12.sqlite /cvmfs/oasis.opensciencegrid.org/jlab/geant4
