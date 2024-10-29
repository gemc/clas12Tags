#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

export
# if we are in the docker container, we need to load the modules
if [[ -z "${DISTTAG}" ]]; then
	echo  "\nNot in container"
else
	echo  "\nIn container: ${DISTTAG}"
	source  /etc/profile.d/localSetup.sh
fi

function compileGEMC {
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
}

cd source
compileGEMC
echo "copying gemc to "$GEMC for experiment tests
cp gemc $GEMC/bin
echo
echo "content of "$GEMC":"
ls -lrt $GEMC
# copying executable and geometry for artifact retrieval
cp gemc experiments /cvmfs/oasis.opensciencegrid.org/jlab/geant4/