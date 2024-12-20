#!/usr/bin/env zsh

# Purpose: create geometry with both TEXT and SQLITE factories and run comparison script

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/gemc_comparison.sh -d ec

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
	echo "-v <digitization variation>: sets DIGITIZATION_VARIATION to the value for the comparisons."
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hd:v:" option; do
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

bank_to_check=""
if [[ $system == "ec" ]]; then
	bank_to_check="EC::adc"
elif [[ $system == "pcal" ]]; then
	bank_to_check="PCAL::adc"
elif [[ $system == "ftof" ]]; then
	bank_to_check="FTOF::adc"
elif [[ $system == "dc" ]]; then
	bank_to_check="DC::tdc"
elif [[ $system == "htcc" ]]; then
	bank_to_check="HTCC::adc"
fi

# build gemc. Not necessary unless something changes in the code
git branch
./ci/build_gemc.sh

mkdir -p /root/logs
log_file=/root/logs/"$system"_output_comparison.log
touch $log_file

# get the clas12.sqlite file. This will be replaced by the actual file
cd experiments/clas12
wget https://userweb.jlab.org/~ungaro/tmp/clas12.sqlite
wget https://userweb.jlab.org/~ungaro/tmp/j4np-1.1.1.tar.gz
tar -zxpvf j4np-1.1.1.tar.gz
yum install -y java-latest-openjdk
cd "$system" || DetectorDirNotExisting
echo "\n > System: $system"

runs=$(runs_for_system)

# geometry comparison
for run in $=runs; do
	variations=$(variations_for_run_and_system $run)
	for variation in $variations; do
		echo "Running gemc from ASCII DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var
		gemc -USE_GUI=0 "$system"_text_"$variation".gcard -N=10 -OUTPUT="hipo, txt_"$run".hipo"     -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var"
		echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var for sanity check
		gemc -USE_GUI=0 "$system"_sqlite.gcard      -N=10 -OUTPUT="hipo, sqlite_sanity_"$run".hipo" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var"

		compare_result=$(../j4np-1.1.1/bin/j4np.sh h5u -compare -b "$bank_to_check" txt_"$run".hipo sqlite_sanity_"$run".hipo)
		echo Comparison:
		echo $compare_result
		sanity_check=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $6}')
		if [[ $sanity_check = "0" ]]; then
			echo "$system:$variation:$run:$digi_var/$digi_var:✅" >>$log_file
		else
			echo "$system:$variation:$run:$digi_var/$digi_var:❌" >>$log_file
		fi

		if [[ $variation != "default" ]]; then
			echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: default
			gemc -USE_GUI=0 "$system"_sqlite.gcard     -N=10 -OUTPUT="hipo, sqlite_"$run".hipo"        -RANDOM=123 -RUNNO="$run"

			compare_result=$(../j4np-1.1.1/bin/j4np.sh h5u -compare -b "$bank_to_check" txt_"$run".hipo sqlite_"$run".hipo)
			echo Comparison:
			echo $compare_result

			actual_check=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $6}')
			if [[ $actual_check = "0" ]]; then
				echo "$system:$variation:$run:$digi_var/default:✅" >>$log_file
			else
				echo "$system:$variation:$run:$digi_var/default:❌" >>$log_file
			fi
		fi

	done

done

echo
cat $log_file
echo
