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
	echo Compiling GEMC with options: "$copt" "$debug"
	echo START_GEMC_COMPILATION $(date) > gemc_build.log | tee -a gemc_build.log
	echo Compiling GEMC with options: "$copt" "$debug" >> gemc_build.log | tee -a gemc_build.log
	scons SHOWENV=1 SHOWBUILD=1 "$=copt" "$=debug" &>> gemc_build.log
	if [ $? -ne 0 ]; then
		echo "scons failed. Log: "
		cat gemc_build.log
		exit 1
	fi
	echo END_GEMC_COMPILATION $(date) >> gemc_build.log | tee -a gemc_build.log
	# checking existence of executable
	echo "Created executable: " $(ls gemc)

	cp gemc $GEMC/bin
	cd ..
	echo "Copying gemc to $GEMC/bin for CI"
}

function create_geo_dbs {
	echo
	echo "Creating all geometry databases with: create_geometry.sh"
	echo START_CREATE_GEOMETRY $(date) > geo_build.log | tee -a geo_build.log
	./create_geometry.sh &>> geo_build.log
	if [ $? -ne 0 ]; then
		echo "create_geometry failed. Log:"
		cat geo_build.log
		exit 1
	fi
	echo
	echo " TEMPORARY PATCH: Restoring some original repo files needed for validation."
	echo " This PATCH will be removed in the once the Real Run Number work for targets is completed."
	echo
	echo RGM targets
	git checkout -- experiments/clas12/targets/target__geometry_2cm-lD2.txt
	git checkout -- experiments/clas12/targets/target__geometry_2cm-lD2-empty.txt
	git checkout -- experiments/clas12/targets/target__materials_2cm-lD2.txt
	git checkout -- experiments/clas12/targets/target__materials_2cm-lD2-empty.txt
	echo RGD targets
 	git checkout -- experiments/clas12/targets/target__geometry_lD2CuSn.txt
 	git checkout -- experiments/clas12/targets/target__geometry_lD2CxC.txt
 	git checkout -- experiments/clas12/targets/target__materials_lD2CuSn.txt
 	git checkout -- experiments/clas12/targets/target__materials_lD2CxC.txt


	echo "Copying experiments ASCII DB and sqlite file to $GEMC for CI"
	cp -r experiments clas12.sqlite source/gemc_build.log geo_build.log geometry_source/build_coatjava.log /cvmfs/oasis.opensciencegrid.org/jlab/geant4

	echo "Changes after creation:"
	git branch ; git status -s >> geo_build.log | tee -a geo_build.log
	echo END_CREATE_GEOMETRY $(date) >> geo_build.log | tee -a geo_build.log

}

compile_gemc
create_geo_dbs
log_gemc_info

echo
echo "Content of artifacts dir /cvmfs/oasis.opensciencegrid.org/jlab/geant4"
ls -lrt /cvmfs/oasis.opensciencegrid.org/jlab/geant4

echo "Content of artifacts experiment dir /cvmfs/oasis.opensciencegrid.org/jlab/geant4/experiments/clas12"
ls -lrt /cvmfs/oasis.opensciencegrid.org/jlab/geant4/experiments/clas12

# copying executable, api and sqlite database for artifact retrieval
# the experiment dir is synced with the bin/cron_gemc_artifact_install_jlab.sh
echo "Copying executable, api and sqlite database for artifact retrieval"
mkdir -p /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp source/gemc /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp -r api /cvmfs/oasis.opensciencegrid.org/jlab/geant4
cp clas12.sqlite /cvmfs/oasis.opensciencegrid.org/jlab/geant4
