#!/bin/zsh

# Purpose: Install gemc artifact in JLab's CVMFS


workdir=/work/clas12/ungaro
fedoradir=/scigroup/cvmfs/geant4/fedora36-gcc12/clas12Tags/dev/experiments
almadir=/scigroup/cvmfs/geant4/almalinux9-gcc11/clas12Tags/dev/experiments


cd $workdir
echo
echo "Cloning clas12Tags repo"
echo
git clone https://github.com/gemc/clas12Tags.git
cd clas12Tags

# remove all files in that are not present in the repo
echo "Removing files not present in $fedoradir"
for file in $(find "$fedoradir" -type f); do
  # Get the relative path of the file from the fedoradir directory
  relative_path="${file#$fedoradir/}"
  # Check if the file does not exist in the 'experiments' subdirectory of the current directory
  if [[ ! -f "experiments/$relative_path" ]]; then
    echo "Removing $file"  # Print the file being removed for confirmation
    rm "$file"
  fi
done

echo "Removing files not present in $almadir"
for file in $(find "$almadir" -type f); do
  # Get the relative path of the file from the fedoradir directory
  relative_path="${file#$almadir/}"
  # Check if the file does not exist in the 'experiments' subdirectory of the current directory
  if [[ ! -f "experiments/$relative_path" ]]; then
    echo "Removing $file"  # Print the file being removed for confirmation
    rm "$file"
  fi
done

echo "Copying files to $fedoradir and $almadir"
cp -r experiments/* $fedoradir
cp -r experiments/* $almadir

echo "Getting last CI artifact in fedora"
cd $fedoradir/..
$workdir/bin/get_last_ci_artifact.py fedora
echo "Getting last CI artifact in almalinux"
cd $almadir/..
$workdir/bin/get_last_ci_artifact.py almalinux

echo
echo Done. Cleaning up and exiting.
cd $HOME
rm -rf $workdir