#!/usr/bin/env zsh

# Purpose: create geometry with both TEXT and SQLITE factories and run comparison script

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/detector_sqlite_dev_comparison.sh -g rgm_fall2021_D.gcard

source ci/env.sh

Help() {
	# Display Help
	echo
	echo "Syntax: variation_run_comparison.sh [-h|d|v]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-g <gcard>: build gemc and runs it for the 2 gcards in clas12-config main and dev branches."
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hg:" option; do
	case $option in
		h)
			Help
			exit
			;;
		g)
			gcard="$OPTARG"
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

	echo
	echo "Comparing bank $bank_to_check for file $outfile1 with $outfile2" for gcard: $gcard
	echo "Comparing bank $bank_to_check for file $outfile1 with $outfile2" for gcard: $gcard >>$log_file_compare
	echo
	echo " ./experiments/clas12/j4np-1.1.1/bin/j4np.sh h5u -compare -b "$bank_to_check" $outfile1 $outfile2 "
	./experiments/clas12/j4np-1.1.1/bin/j4np.sh h5u -compare -b "$bank_to_check" $outfile1 $outfile2 >temp_log
	cat temp_log >>$log_file_compare
	compare_result=$(cat temp_log | grep "$bank_to_check")
	echo "Comparison results:"
	echo "Comparison results:">>$log_file_compare
	echo $compare_result
	echo $compare_result>>$log_file_compare
	check1=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $4}')
	check2=$(echo $compare_result | grep "$bank_to_check" | grep \| | awk '{print $6}')

	# remove :: from $bank_to_check
	bank_to_write=$(echo $bank_to_check | sed 's/::/_/g')

	# if both checks are 0, then the comparison is successful
	if [[ $check1 = "0" && $check2 = "0" ]]; then
		echo "$experiment:$bank_to_write:✅" >>$log_file_detail
	else
		echo "$experiment:$bank_to_write:❌" >>$log_file_detail
	fi
}

summarize_log() {
	if grep -q "❌" "$log_file_detail"; then
		echo   "$experiment:❌" >>"$log_file_summary"
	elif grep -q "✅" "$log_file_detail"; then
		echo   "$experiment:✅" >>"$log_file_summary"
	fi
}

# bank_to_check space separated list
banks_to_check="FTCAL::adc DC::tdc ECAL::adc FTOF::adc HTCC::adc BMT::adc FMT::adc CTOF::adc CND::adc BST::adc LTCC::adc RICH::tdc"

[[ -d clas12-config-dev  ]]  && echo clas12-config-dev exist  || git clone -b dev https://github.com/JeffersonLab/clas12-config clas12-config-dev
[[ -d clas12-config-main  ]] && echo clas12-config-main exist || git clone -b main https://github.com/JeffersonLab/clas12-config clas12-config-main

mkdir -p /root/logs
experiment=$(echo $gcard | sed 's/.gcard//g')
log_file_run=/root/logs/"$experiment"_output_run.log
log_file_compare=/root/logs/"$experiment"_output_compare.log
log_file_detail=/root/logs/"$experiment"_output_details.log
log_file_summary=/root/logs/"$experiment"_output_summary.log
touch  $log_file_run $log_file_compare $log_file_detail $log_file_summary

nevents=100

# running gemc with TEXT factory, $digi_var, and compare it with SQLITE factory, default

gcard_dev=clas12-config-dev/gemc/dev/$gcard
gcard_main=clas12-config-main/gemc/dev/$gcard
# remove .gcard from gcard
outfile1="dev_"$experiment".hipo"
outfile2="main_"$experiment".hipo"

echo   "Running gemc for dev gcard: $gcard_dev, log to $log_file_run "
echo   "Running gemc for dev gcard: $gcard_dev " >>$log_file_run
gemc   -USE_GUI=0 "$gcard_dev"  -N="$nevents" -OUTPUT="hipo, $outfile1" -RANDOM=123 -RUNNO="11" -DIGITIZATION_VARIATION="default" -BEAM_P="e-, 4*GeV, 50*deg, 20*deg" -SPREAD_P="1*GeV, 30*deg, 180*deg" >>$log_file_run

echo   "Running gemc for main gcard: $gcard_main, log to $log_file_run"
echo   "Running gemc for main gcard: $gcard_main " >>$log_file_run
gemc   -USE_GUI=0 "$gcard_main" -N="$nevents" -OUTPUT="hipo, $outfile2" -RANDOM=123 -RUNNO="11" -DIGITIZATION_VARIATION="default" -BEAM_P="e-, 4*GeV, 50*deg, 20*deg" -SPREAD_P="1*GeV, 30*deg, 180*deg" >>$log_file_run

echo
echo   "\n\nContent of directory after running gemc: "
echo   "\n\nContent of directory after running gemc: " >>$log_file_run
ls -l
ls -l >>$log_file_run
echo

for bank_to_check in   $=banks_to_check; do
	echo "Comparing bank $bank_to_check for files: $outfile1 and $outfile2"
	compare_output $bank_to_check $outfile1 $outfile2
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
