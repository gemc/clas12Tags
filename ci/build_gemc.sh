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
	ls -lrt > geo_build.log | tee -a geo_build.log
	if [ $? -ne 0 ]; then
		echo "create_geometry failed. Log:"
		cat geo_build.log
		exit 1
	fi

	echo "Copying experiments ASCII DB and sqlite file to $ARTIFACT_DIR for CI"
	cp -r experiments clas12.sqlite source/gemc_build.log geo_build.log geometry_source/build_coatjava.log $ARTIFACT_DIR

	echo
	echo "Changes after creation:"
	git branch ; git status -s >> geo_build.log | tee -a geo_build.log
	echo END_CREATE_GEOMETRY $(date) >> geo_build.log | tee -a geo_build.log

}

compile_gemc
create_geo_dbs
log_gemc_info
echo
echo "Content of $GEMC after geo creation:"
ls -lrt $GEMC
echo
echo "Content of artifacts dir $ARTIFACT_DIR:"
ls -lrt $ARTIFACT_DIR
echo
# copying executable, api and sqlite database for artifact retrieval
echo "Copying executable, experiments, api, sqlite database and mlibrary for artifact retrieval"
mkdir -p $ARTIFACT_DIR/bin
cp source/gemc $ARTIFACT_DIR/bin
cp -r experiments $ARTIFACT_DIR
cp -r api $ARTIFACT_DIR
cp clas12.sqlite $ARTIFACT_DIR
# mlibrary
mkdir -p $ARTIFACT_DIR/mlibrary/lib
cp $MLIBRARY/lib/* $ARTIFACT_DIR/mlibrary/lib
cp -r $MLIBRARY/frequencySyncSignal $MLIBRARY/options $MLIBRARY/include $ARTIFACT_DIR/mlibrary