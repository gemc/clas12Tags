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

	build_log=gemc_build.log

	cd source
	# getting number of available CPUS
	copt=" -j"$(getconf _NPROCESSORS_ONLN)" OPT=1"
	echo
	echo Compiling GEMC with options: "$copt" "$debug"
	echo START_GEMC_COMPILATION $(date) | tee $build_log
	echo Compiling GEMC with options: "$copt" "$debug" | tee -a $build_log
	scons SHOWENV=1 SHOWBUILD=1 "$=copt" "$=debug" | tee -a $build_log
	if [ $? -ne 0 ]; then
		echo "scons failed. Log: "
		cat $build_log
		exit 1
	fi
	echo END_GEMC_COMPILATION $(date) | tee -a $build_log
	# checking existence of executable
	echo "Created executable: " $(ls gemc)

	cp gemc $GEMC/bin
	cd ..
	echo "Copying gemc to $GEMC/bin for CI"
}

function create_geo_dbs {
	geo_log=geo_build.log

	echo
	echo "Creating all geometry databases with: create_geometry.sh"
	echo START_CREATE_GEOMETRY $(date) | tee $geo_log
	./create_geometry.sh | tee -a $geo_log
	ls -lrt | tee -a $geo_log
	if [ $? -ne 0 ]; then
		echo "create_geometry failed. Log:"
		cat $geo_log
		exit 1
	fi

	echo
	echo "Changes after creation:"
	echo END_CREATE_GEOMETRY $(date) | tee -a $geo_log
	git branch ; git status -s | tee -a $geo_log

	echo Final experiments/clas12 content | tee -a $geo_log
	ls -R experiments/clas12 | tee -a $geo_log

	echo "Copying experiments ASCII DB and sqlite file to $ARTIFACT_DIR for CI"
	cp -r experiments clas12.sqlite source/gemc_build.log geo_build.log geometry_source/build_coatjava.log $ARTIFACT_DIR
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