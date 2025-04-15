#!/usr/bin/env zsh

# Purpose: create geometry with both TEXT and SQLITE factories and run comparison script

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/detector_sqlite_dev_comparison.sh -d ec -v default

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

compare_output() {
	bank_to_check=$1
	outfile1=$2
	outfile2=$3
	digi_var1=$4
	digi_var2=$5
	geometry_variation=$6

	echo
	echo "Comparing file $outfile1 with $outfile2" for geometry variation: $geometry_variation, digi_var1: $digi_var1, digi_var2: $digi_var2
	echo "Comparing file $outfile1 with $outfile2" for geometry variation: $geometry_variation, digi_var1: $digi_var1, digi_var2: $digi_var2 >>$log_file_compare
	echo
	echo
	../j4np-1.1.1/bin/j4np.sh h5u -compare -b "$bank_to_check" $outfile1 $outfile2 >temp_log
	cat temp_log >>$log_file_compare
	compare_result=$(cat temp_log | grep "$bank_to_check")
	echo Comparison between files $outfile1 and $outfile2
	echo $compare_result
	check1=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $4}')
	check2=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $6}')

	# remove :: from $bank_to_check
	bank_to_write=$(echo $bank_to_check | sed 's/::/_/g')

	# if both checks are 0, then the comparison is successful
	if [[ $check1 = "0" && $check2 = "0" ]]; then
		echo "$system:$variation:$run:$bank_to_write:$digi_var1/$digi_var2:✅" >>$log_file_detail
	else
		echo "$system:$variation:$run:$bank_to_write:$digi_var1/$digi_var2:❌" >>$log_file_detail
	fi
}

summarize_log() {
	if  grep -q "❌" "$log_file_detail"; then
		echo     "$system:$digi_var:❌" >>"$log_file_summary"
	elif  grep -q "✅" "$log_file_detail"; then
		echo     "$system:$digi_var:✅" >>"$log_file_summary"
	fi
}

# bank_to_check space separated list
banks_to_check=""
if [[ $system == "ec" || $system == "pcal" ]]; then
	banks_to_check="ECAL::adc"
elif [[ $system == "ftof" ]]; then
	banks_to_check="FTOF::adc"
elif [[ $system == "dc" ]]; then
	banks_to_check="DC::tdc"
elif [[ $system == "htcc" ]]; then
	banks_to_check="HTCC::adc"
elif [[ $system == "ctof" ]]; then
	banks_to_check="CTOF::adc"
elif [[ $system == "cnd" ]]; then
	banks_to_check="CND::adc"
elif [[ banks_to_check == "bst" ]]; then
	banks_to_check="BST::adc"
elif [[ $system == "bmt" ]]; then
	banks_to_check="BMT::adc"
elif [[ $system == "ltcc" ]]; then
	banks_to_check="LTCC::adc"
elif [[ $system == "rich" ]]; then
	banks_to_check="RICH::tdc"
elif [[ $system == "micromegas" ]]; then
	banks_to_check="BMT::adc FMT::adc"
elif [[ $system == "ft" || $system == "beamline" || $system = "magnets" ]]; then
	banks_to_check="FTCAL::adc FTHODO::adc FTTRK::adc"
fi

cd "experiments/clas12/$system" || DetectorDirNotExisting
echo "\n > System: $system"
echo " > DIGITIZATION_VARIATION: $digi_var"
echo " > GEMC: $(which gemc)"
echo " > GEMC compiled on $(date)"
echo

mkdir -p /root/logs
log_file_run=/root/logs/"$system"_output_run.log
log_file_compare=/root/logs/"$system"_output_compare.log
log_file_detail=/root/logs/"$system"_output_details.log
log_file_summary=/root/logs/"$system"_output_summary.log
touch  $log_file_run $log_file_compare $log_file_detail $log_file_summary


runs=$(runs_for_system)
nevents=200

# digitization output comparison
# $digi_var can be: default, rga_spring2018_mc, rga_fall2018_mc
for run in $=runs; do
	variations=$(variations_for_run_and_system $run)
	for variation in $variations; do

		# running gemc with TEXT factory, $digi_var, and compare it with SQLITE factory, default

		gcard1="$system"_text_"$variation".gcard
		gcard2="$system"_sqlite.gcard
		outfile1="txt_"$run".hipo"
		outfile2="sqlite_"$run".hipo"
		outfile3="sanity_sqlite_"$run".hipo"

		echo "Running gemc from ASCII DB for $system, run: $run, geometry variation: $variation digi_variation: $digi_var to log $log_file_run"
		echo "Running gemc from ASCII DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var >>$log_file_run
		gemc -USE_GUI=0 $gcard1 -N=$nevents -OUTPUT="hipo, $outfile1" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var" >>$log_file_run

		echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation, digi_variation: default to log $log_file_run"
		echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: default >>$log_file_run
		gemc -USE_GUI=0 $gcard2 -N=$nevents -OUTPUT="hipo, $outfile2" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="default" >>$log_file_run
		echo

		# sanity check: running gemc with SQLITE factory, same variation as TEXT factory
		if [[ $digi_var != "default" ]]; then

			echo "Running gemc from SQLITE DB for $system, run: $run, geometry variation: $variation", digi_variation: $digi_var >>$log_file_run
			gemc -USE_GUI=0 $gcard2 -N=$nevents -OUTPUT="hipo, $outfile3" -RANDOM=123 -RUNNO="$run" -DIGITIZATION_VARIATION="$digi_var" >>$log_file_run
		fi

		echo "\n\nContent of directory after running gemc: "
		echo "\n\nContent of directory after running gemc: ">>$log_file_run
		ls -l
		ls -l>>$log_file_run
		echo

		for bank_to_check in $=banks_to_check; do
			echo "Comparing bank $bank_to_check for files: $outfile1 and $outfile2 for variations $digi_var default"
			echo "Comparing bank $bank_to_check for files: $outfile1 and $outfile2 for variations $digi_var default">>$log_file_run
			compare_output $bank_to_check $outfile1 $outfile2 $digi_var default
			# sanity check: running gemc with SQLITE factory, same variation as TEXT factory
			if [[ $digi_var != "default" ]]; then
				compare_output $bank_to_check $outfile1 $outfile3 $digi_var $digi_var
			fi
		done

	done

done

echo
echo Final hipo files:
echo
ls -l *.hipo
echo
echo

echo Content of $log_file_detail:
cat $log_file_detail
echo
echo
summarize_log
echo
echo Content of $log_file_summary:
cat $log_file_summary
echo
echo
