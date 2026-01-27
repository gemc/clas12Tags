#!/bin/zsh

# Purpose: Install gemc artifact in JLab's CVMFS
# To be run as the following cron:
# 03  6  *  *  *  $HOME/tmp/clas12Tags/bin/cron_gemc_artifact_install_jlab.sh   > $HOME/tmp/clas12Tags/log_install.log

workdir=/work/clas12/ungaro/tmp
fedoradir=/scigroup/cvmfs/geant4/fedora36-gcc12/clas12Tags/dev/experiments
almadir=/scigroup/cvmfs/geant4/almalinux9-gcc11/clas12Tags/dev/experiments

mkdir -p $workdir
cd $workdir
echo
echo "Cloning or pulling clas12Tags repo"
if [ -d clas12Tags ]; then
	cd clas12Tags
	git pull
else
	git clone https://github.com/gemc/clas12Tags.git
	cd clas12Tags
fi

# remove all files in that are not present in the repo
echo "Removing files not present in $fedoradir"
for file in $(find "$fedoradir" -type f); do
	# Get the relative path of the file from the fedoradir directory
	relative_path="${file#$fedoradir/}"
	# Check if the file does not exist in the 'experiments' subdirectory of the current directory
	if [[ ! -f "experiments/$relative_path" ]]; then
		echo "Removing $file" # Print the file being removed for confirmation
		rm "$file"
	fi
done

echo "Removing files not present in $almadir"
for file in $(find "$almadir" -type f); do
	# Get the relative path of the file from the fedoradir directory
	relative_path="${file#$almadir/}"
	# Check if the file does not exist in the 'experiments' subdirectory of the current directory
	if [[ ! -f "experiments/$relative_path" ]]; then
		echo "Removing $file" # Print the file being removed for confirmation
		rm "$file"
	fi
done

echo "Copying experiments files to $fedoradir and $almadir"
cp -r experiments/* $fedoradir
cp -r experiments/* $almadir

echo "Getting last CI artifact in fedora"
cd $fedoradir/..
echo "Current dir: " $(pwd)
$workdir/clas12Tags/bin/get_last_ci_artifact.py fedora
# copy mlibrary
cp -r mlibrary/* ../../mlibrary/dev
# remove gemc.zip if it exists
if [ -f gemc.zip ]; then
	rm gemc.zip
fi

echo "Getting last CI artifact in almalinux"
cd $almadir/..
echo "Current dir: " $(pwd)
$workdir/clas12Tags/bin/get_last_ci_artifact.py almalinux
# copy mlibrary
cp -r mlibrary/* ../../mlibrary/dev
# remove gemc.zip if it exists
if [ -f gemc.zip ]; then
	rm gemc.zip
fi

echo
echo Done!