#!/usr/bin/env zsh

# Purpose: create geometry with both TEXT and SQLITE factories and run comparison script

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/variation_run_comparison.sh -d ec

source ci/env.sh
compare_exe=$(pwd)/api/perl/db_compare.py

Help() {
	# Display Help
	echo
	echo "Syntax: variation_run_comparison.sh [-h|d]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-d <system>: build geometry and runs and run comparison script for the system."
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hd:" option; do
	case $option in
		h)
			Help
			exit
			;;
		d)
			system="$OPTARG"
			;;
		\?) # Invalid option
			echo "Error: Invalid option"
			exit 1
			;;
	esac
done

DetectorDirNotExisting() {
	echo "System directory: $system not existing"
	Help
	exit 3
}

# returns runs to test
runs_for_system() {
	# if system is ec returns 11 and 3029
	if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
		echo "11 3029"
	elif [[ $system == "dc" ]]; then
		echo "11"
	elif [[ $system == "htcc" ]]; then
		echo "11 3029 4763"
	fi
}

variations_for_run_and_system()  {
	if [[ $1 == "11" ]]; then
		echo "default"
	elif [[ $1 == "3029" ]]; then
		if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
			echo "rga_fall2018"
		elif [[ $system == "htcc" ]]; then
			echo "rga_spring2018"
		fi
	elif [[ $1 == "4763" ]]; then
			echo "rga_fall2018"
	fi
}

digitization_for_run_and_system()  {
	if [[ $1 == "11" ]]; then
		echo "default"
	elif [[ $1 == "3029" ]]; then
		if [[ $system == "ec" ]]; then
			echo "rga_fall2018_mc"
		fi
	fi
}

geo_log_file=/root/logs/"$system"_geo_comparison.log
mkdir -p /root/logs
#./ci/build_gemc.sh
cd experiments/clas12
touch $geo_log_file

# get the clas12.sqlite file. This will be replaced by the actual file
wget https://userweb.jlab.org/~ungaro/tmp/clas12.sqlite
cd "$system" || DetectorDirNotExisting
echo "\n > System: $system"

runs=$(runs_for_system)

# loop over runs and get the variation
for run in $=runs; do
	variations=$(variations_for_run_and_system $run)
	for variation in $variations; do
		echo "Comparing geometry for $system, run: $run, variation: $variation", compare argument: "$system"__geometry_"$variation".txt ../clas12.sqlite "$system" "$run" default
		$compare_exe "$system"__geometry_"$variation".txt ../clas12.sqlite "$system" "$run" default
		if [ $? -ne 0 ]; then
			echo "$system:$variation:$run:❌" >>$geo_log_file
		else
			echo "$system:$variation:$run:✅" >>$geo_log_file
		fi
	done
done

echo
cat $geo_log_file
echo
