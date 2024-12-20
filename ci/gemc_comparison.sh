#!/usr/bin/env zsh

# Purpose: create geometry with both TEXT and SQLITE factories and run comparison script

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/variation_run_comparison.sh -d ec

source ci/env.sh

Help() {
	# Display Help
	echo
	echo "Syntax: variation_run_comparison.sh [-h|d|v]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-d <system>: build gemc and runs it for the system."
	echo "-v <digitation variation>: sets DIGITIZATION_VARIATION to the value for the comparisons."
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
		v)
			digi_var="$OPTARG"
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

# build gemc
./ci/build_gemc.sh

mkdir -p /root/logs
log_file=/root/logs/"$system"_output_comparison.log
touch $log_file

# get the clas12.sqlite file. This will be replaced by the actual file
cd experiments/clas12
wget https://userweb.jlab.org/~ungaro/tmp/clas12.sqlite
cd "$system" || DetectorDirNotExisting
echo "\n > System: $system"

# get the clas12.sqlite file. This will be replaced by the actual file
wget https://userweb.jlab.org/~ungaro/tmp/clas12.sqlite
cd "$system" || DetectorDirNotExisting
echo "\n > System: $system"

runs=$(runs_for_system)

digi_variation=$(digitization_variations)
# geometry comparison
for run in $=runs; do
	variations=$(variations_for_run_and_system $run)
	for variation in $variations; do
		echo "Running gemc from ASCII DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var
		gemc -USE_GUI=0 "$system"_text_"$variation".gcard -N=10 -OUTPUT="hipo, txt_"$run".hipo" -RANDOM=123 -RUNNO="$run"  -DIGITIZATION_VARIATION="$digi_var"
		echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var for sanity check
		gemc -USE_GUI=0 "$system"_sqlite.gcard.gcard   -N=10 -OUTPUT="hipo, sqlite_sanity_"$run".hipo" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var"
		echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: default
		gemc -USE_GUI=0 "$system"_sqlite.gcard.gcard   -N=10 -OUTPUT="hipo, sqlite_"$run".hipo" -RANDOM=123 -RUNNO="$run"

		echo "$system:$variation:$run:$digi_var/$digi_var:✅" >> $log_file
		echo "$system:$variation:$run:$digi_var/$default:❌" >> $log_file

	done
done

echo
cat $log_file
echo
