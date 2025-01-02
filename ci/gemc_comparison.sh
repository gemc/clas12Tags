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

compare_output() {
	bank_to_check=$1
	outfile1=$2
	outfile2=$3
	digi_var1=$4
	digi_var2=$5

	../j4np-1.1.1/bin/j4np.sh h5u -compare -b "$bank_to_check" $outfile1 $outfile2 >>$log_file_compare
	compare_result=$(cat $log_file_compare)
	echo Comparison between $outfile1 and $outfile2
	echo $compare_result
	check1=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $4}')
	check2=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $6}')

	# remove :: from $bank_to_check
	bank_to_write=$(echo $bank_to_check | sed 's/::/_/g')

	# if both checks are 0, then the comparison is successful
	if [[ $check1 = "0" && $check2 = "0" ]]; then
		echo "$system:$variation:$run:$bank_to_write:$digi_var1/$digi_var2:✅" >>$log_file
	else
		echo "$system:$variation:$run:$bank_to_write:$digi_var1/$digi_var2:❌" >>$log_file
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
log_file=/root/logs/"$system"_output_summary.log
log_file_run=/root/logs/"$system"_output_run.log
log_file_compare=/root/logs/"$system"_output_compare.log
touch $log_file $log_file_run $log_file_compare

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

		# $digi_var can be: default, rga_spring2018_mc, rga_fall2018_mc

		# running gemc with TEXT factory, $digi_var, and compare it with SQLITE factory, default

		gcard1="$system"_text_"$variation".gcard
		gcard2="$system"_sqlite.gcard
		outfile1="txt_"$run".hipo"
		outfile2="sqlite_"$run".hipo"

		echo "Running gemc from ASCII DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var >>$log_file_run
		gemc -USE_GUI=0 $gcard1 -N=10 -OUTPUT="hipo, $outfile1" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var" >>$log_file_run

		echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: default >>$log_file_run
		gemc -USE_GUI=0 $gcard2 -N=10 -OUTPUT="hipo, $outfile2" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="default" >>$log_file_run

		compare_output $bank_to_check $outfile1 $outfile2 $digi_var default

		# sanity check: running gemc with SQLITE factory, same variation as TEXT factory
		if [[ $digi_var != "default" ]]; then

			gcard2="$system"_sqlite.gcard
			outfile2="sqlite_"$run".hipo"
			output2=" -OUTPUT=\"hipo, $outfile2\""

			echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var >>$log_file_run
			gemc -USE_GUI=0 $gcard2 -N=10 -OUTPUT="hipo, $outfile2" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var" >>$log_file_run

			compare_output $bank_to_check $outfile1 $outfile2 $digi_var $digi_var

		fi

	done

done

echo
echo
