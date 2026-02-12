#!/bin/zsh

cdir=$(pwd)
export COATJAVA=$cdir/geometry_source/coatjava
export PATH=$PATH:$COATJAVA/bin

# CLAS12
all_dets="alert band beamline bst cnd ctof dc ddvcs ec fluxDets ft ftof ftofShield htcc ltcc magnets micromegas pcal rich rtpc targets muvt upstream"

function printHelp() {
    cat <<EOF

Usage: create_geometry.sh [coatjava release options] [detector]

Coatjava options (optional – at most one of -d|-l|-t|-g):
  -l                 use latest tag (default)
  -t <tag>           use specific tag, like 12.0.4t
  -g <github_url>    use custom github URL
  -c CCDB_CONNECTION use custom CCDB_CONNECTION
  -h                 show this help

If a detector is given, only that detector will be built; otherwise every detector below is processed:

  $all_dets

EOF
}

coatjava_args=("-l")         # default behaviour = latest tag
explicit_coatjava=0          # did the user pass a coatjava flag?
ccdb_conn="mysql://clas12reader@clasdb.jlab.org/clas12"

while getopts ":lt:g:c:h" opt; do
  case "$opt" in
    l) coatjava_args=("-l"); explicit_coatjava=1 ;;
    t) coatjava_args=("-t" "$OPTARG"); explicit_coatjava=1 ;;
    g) coatjava_args=("-g" "$OPTARG"); explicit_coatjava=1 ;;
    c) ccdb_conn=$OPTARG ;;
    h) printHelp; exit 0 ;;
    :) echo "Error: -$OPTARG requires an argument." >&2; exit 1 ;;
    \?) echo "Error: unknown option -$OPTARG" >&2; printHelp; exit 1 ;;
  esac
done
shift $((OPTIND - 1))        # drop parsed options

export CCDB_CONNECTION=$ccdb_conn
echo "CCDB_CONNECTION=$CCDB_CONNECTION"

# Positional argument = detector (optional)
if [[ $# -gt 0 ]]; then
  detector="$1"
  if [[ ! " $all_dets " =~ " $detector " ]]; then
    echo "Error: '$detector' is not a recognised detector." >&2
    exit 1
  fi
  all_dets="$detector"
fi


function find_subdirs_with_file() {
	local subdirs_with_file=() # Initialize an empty array to store matching subdirs

	for file in $(find . -name "cad*.gxml"); do
		# subdir is the full path of the directory containing the file
		subdir=$(dirname $file)
		subdirs_with_file+=($subdir) # Add the directory to the array
	done

	# remove duplicates
	subdirs_with_file=($(echo "${(@u)subdirs_with_file}"))
	echo "${subdirs_with_file[@]}" # Return the array by echoing it
}

function copyFilesAndCadDirsTo() {
	destination=$1
	rm -rf $destination
	mkdir -p $destination
	cp *.txt "$destination/"
	cp *.gcard "$destination/"

	cadDirs=$(find_subdirs_with_file)
	for cadDir in $=cadDirs; do
		echo Copying CAD Subdirs: $cadDir to $destination
		# copy $cadDir preserving full path. Notice it needs the relative path.
		rsync -aR "./$cadDir" "$destination/"
	done
}


# Creating new clas12.sqlite DB
if [ ! -f "clas12.sqlite" ]; then
	$cdir/api/perl/sqlite.py -n clas12.sqlite
fi

cd geometry_source

# if the directory coatjava does not exist, run the script to create it
if [[ ! -d coatjava || $explicit_coatjava -eq 1 ]]; then
  [[ -d coatjava ]] && echo "Re‑installing coatjava with specified options..."
  ./install_coatjava.sh "${coatjava_args[@]}"
	if [[ $? -ne 0 ]]; then
		echo "Error: coatjava build failed. See ../build_coatjava.log for details."
		exit 1
	fi
fi

# loop over all dets
for dete in $=all_dets; do
	cd $dete
	echo
	echo " > Removing $cdir/experiments/clas12/$dete"
	echo " > And building $dete"
	echo
	rm -rf "$cdir/experiments/clas12/$dete"

	# pre-requirements
	if [ $dete = "ltcc" ]; then
		echo " > Running LTCC mirrors.C"
		root -q -b mirrors.C
	fi

	# main run
	if [[ -f "./$dete.pl" ]]; then
		./"$dete.pl" config.dat
	if [[ $? -ne 0 ]]; then
		echo "Error: building $dete failed. Check the geometry build log for details."
		exit 1
	fi
	fi
	copyFilesAndCadDirsTo "$cdir/experiments/clas12/$dete"

	cd ..
done
