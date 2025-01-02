#!/usr/bin/env zsh

# Purpose: create geometry with both TEXT and SQLITE factories and run comparison script

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/geometry_comparison.sh -d ec

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
	echo "-d <system>: runs geometry comparisons between ASCII and SQLITE factories for the system."
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


mkdir -p /root/logs
log_file=/root/logs/"$system"_geo_comparison.log
touch $log_file

# get the clas12.sqlite file. This will be replaced by the actual file
cd experiments/clas12
wget https://userweb.jlab.org/~ungaro/tmp/clas12.sqlite >/dev/null 2>&1
cd "$system" || DetectorDirNotExisting
echo "\n > System: $system"

runs=$(runs_for_system)

# geometry comparison
for run in $=runs; do
	variations=$(variations_for_run_and_system $run)
	for variation in $variations; do
		echo "Comparing geometry for $system, run: $run, geometry variation: $variation", compare argument: "$system"__geometry_"$variation".txt ../clas12.sqlite "$system" "$run" default
		$compare_exe "$system"__geometry_"$variation".txt ../clas12.sqlite "$system" "$run" default
		if [ $? -ne 0 ]; then
			echo "$system:$variation:$run:❌" >> $log_file
		else
			echo "$system:$variation:$run:✅" >> $log_file
		fi
	done
done

echo
cat $log_file
echo
