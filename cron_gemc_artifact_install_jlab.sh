#!/bin/zsh

# Purpose: Install gemc artifact in JLab's CVMFS


workdir=/work/clas12/ungaro
fedoradir=/scigroup/cvmfs/geant4/fedora36-gcc12/clas12Tags/dev/experiments
almadir=/scigroup/cvmfs/geant4/almalinux9-gcc11/clas12Tags/dev/experiments


cd $workdir
git clone https://github.com/gemc/clas12Tags.git
cd clas12Tags

# remove all files in that are not present in the repo
for file in $(find "$fedoradir" -type f); do
  # Get the relative path of the file from the fedoradir directory
  relative_path="${file#$fedoradir/}"
  # Check if the file does not exist in the 'experiments' subdirectory of the current directory
  if [[ ! -f "experiments/$relative_path" ]]; then
    echo "Removing $file"  # Print the file being removed for confirmation
    rm "$file"
  fi
done

for file in $(find "$almadir" -type f); do
  # Get the relative path of the file from the fedoradir directory
  relative_path="${file#$almadir/}"
  # Check if the file does not exist in the 'experiments' subdirectory of the current directory
  if [[ ! -f "experiments/$relative_path" ]]; then
    echo "Removing $file"  # Print the file being removed for confirmation
    rm "$file"
  fi
done

cp -r experiments/* $fedoradir
cp -r experiments/* $almadir

cd $fedoradir/..
$workdir/bin/get_last_ci_artifact.py fedora
cd $almadir/..
$workdir/bin/get_last_ci_artifact.py almalinux