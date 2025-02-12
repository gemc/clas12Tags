#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

source ci/env.sh

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
echo "Copying gemc to "$GEMC/bin for CI
cp gemc $GEMC/bin
cd ..
cp -r experiments $GEMC
echo
echo "Content of "$GEMC":"
ls -lrt $GEMC

# copying executable and geometry for artifact retrieval
mkdir -p /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin
cp source/gemc /cvmfs/oasis.opensciencegrid.org/jlab/geant4/bin

cd experiments/clas12
wget https://userweb.jlab.org/~ungaro/tmp/clas12.sqlite  >/dev/null 2>&1
echo "Content of `pwd`:"
ls -lrt