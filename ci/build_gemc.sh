#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

source ci/env.sh

debug=""
# if the option $1 is set to "DEBUG" then set debug to "DEBUG=1"
if [ "$1" = "DEBUG" ]; then
	debug="DEBUG=1"
fi


function compile_gemc {
	cd source
	# getting number of available CPUS
	copt=" -j"$(getconf _NPROCESSORS_ONLN)" OPT=1"
	echo
	echo Compiling GEMC with options: "$copt" $debug
	scons SHOWENV=1 SHOWBUILD=1 $copt $debug > gemc_build.log 2>&1
	# checking existence of executable
	ls gemc
	if [ $? -ne 0 ]; then
		echo gemc executable not found
		exit 1
	fi
	cp gemc $GEMC/bin
	cd ..
	echo "Copying gemc to $GEMC/bin for CI"
}

function create_geo_dbs {
	./create_geometry.sh > geo_build.log 2>&1
	echo "Copying experiments ASCII DB and sqlite file to $GEMC for CI"
	cp -r experiments clas12.sqlite gemc_build.log geo_build.log build_coatjava.log /cvmfs/oasis.opensciencegrid.org/jlab/geant4
	echo
	echo "Changes:"
	git branch ; git status -s
}

compile_gemc
create_geo_dbs
log_gemc_info

echo "Content of artifacts dir /cvmfs/oasis.opensciencegrid.org/jlab/geant4"
ls -lrt /cvmfs/oasis.opensciencegrid.org/jlab/geant4

echo "Content of artifacts experiment dir /cvmfs/oasis.opensciencegrid.org/jlab/geant4/experiments/clas12"
ls -lrt -R /cvmfs/oasis.opensciencegrid.org/jlab/geant4/experiments/clas12

# copying executable, api and sqlite database for artifact retrieval
# the experiment dir is synced with the bin/cron_gemc_artifact_install_jlab.sh
mkdir -p /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp source/gemc /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp -r api /cvmfs/oasis.opensciencegrid.org/jlab/geant4
cp clas12.sqlite /cvmfs/oasis.opensciencegrid.org/jlab/geant4
