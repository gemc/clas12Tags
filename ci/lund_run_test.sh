#!/usr/bin/env zsh

# Purpose: runs gemc using all the gcards in clas12-config dev branch

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/gcard_run_test.sh

source ci/env.sh

Help() {
	# Display Help
	echo
	echo "Syntax: gcard_run_test.sh [-h|g|l]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-g: gcard to be used"
	echo "-l: lund file base name"
	echo
}

if [ $# -eq 0 ]; then
	Help
	exit 1
fi

while getopts ":hg:l:" option; do
	case $option in
		h)
			Help
			exit
			;;
		g)
			gcard="clas12-config/gemc/dev/$OPTARG"
			;;
		l)
			ntracks="$OPTARG"
			;;
		\?)    # Invalid option
			echo "Error: Invalid option"
			exit 1
			;;
	esac
done

ExperimentNotExisting() {
	gcard=$1
	echo "Gcard: $gcard not existing"
	Help
	exit 3
}

[[ -d clas12-config ]] && echo clas12-config exist || git clone -b dev https://github.com/JeffersonLab/clas12-config
echo " > Gcard: $gcard\n"

if [[ ! -f "$gcard" ]]; then
	ExperimentNotExisting $gcard
fi

nevents=200
mkdir -p /root/logs
log_file=/root/logs/"$ntracks"_tracks.log
gemc_log=/root/logs/gemc.log

# if $ntracks is clasdis then use clasdis lund file
if [[ $ntracks == "clasdis_all" || $ntracks == "clasdis_acc" ]]; then
	cp ci/generated_events/"$ntracks".dat events.dat
	if [[ $ntracks == "clasdis_all" ]]; then
		echo "Using $nevents events from lund file generated with clasdis --trig 200 --docker"
	elif [[ $ntracks == "clasdis_acc" ]]; then
		echo "Using $nevents events from lund file generated with clasdis --t 15 35 --trig 200 --docker"
	fi
elif [[ $ntracks == "clasdis_all_no_int" || $ntracks == "clasdis_all_savemothers" ]]; then
	cp ci/generated_events/clasdis_all.dat events.dat
	echo "Using clasdis_all events from lund file generated with clasdis --trig 200 --docker"
else
	lund_file="ci/generated_events/"$ntracks"_tracks.dat"
	echo "Generating file events.dat with $nevents events from lund file: $lund_file"
	./ci/generated_events/randomize_particles.py --nevents $nevents -o events.dat --theta-min 7 --theta-max 120 --seed 123 $lund_file
fi

options_general="-INPUT_GEN_FILE=\"lund, events.dat\" -NGENP=100 -USE_GUI=0 -N=$nevents -PRINT_EVENT=10 -GEN_VERBOSITY=10 -OUTPUT=\"hipo, gemc.hipo\""
options_vertex=" -RANDOMIZE_LUND_VZ=\"-1.94*cm, 2.5*cm, reset\" -BEAM_SPOT=\"0.0*mm, 0.0*mm, 0.0*mm, 0.0*mm, 0*deg, reset\" -RASTER_VERTEX=\"0.0*cm, 0.0*cm, reset\" "
options_fields=" -SCALE_FIELD=\"binary_torus, -1.00\" -SCALE_FIELD=\"binary_solenoid, -1.00\" "
options_integrated=" -INTEGRATED_RAW=\"*\""
options_mothers=" -SAVE_ALL_MOTHERS=\"1\""
options_output=" -OUTPUT='hipo, gemc.hipo'"

gemc_opts="$gemc_general $options_vertex $options_fields $options_output"

# if $ntracks is NOT clasdis_all_no_int, add integrated option
if [[ $ntracks != "clasdis_all_no_int" ]]; then
	gemc_opts="$gemc_opts $options_integrated"
fi

if [[ $ntracks == "clasdis_all_savemothers" ]]; then
	gemc_opts="$gemc_opts $options_integrated $options_mothers"
fi

echo "Running gemc with options: $gemc_opts and gcard: $gcard"

gemc $gemc_opts $gcard | sed '/G4Exception-START/,/G4Exception-END/d' >$gemc_log

exitCode=$?

if [[ $exitCode != 0 ]]; then
	echo exiting with gemc exitCode: $exitCode
	exit $exitCode
fi

printf '%s %s %s\n' "$nevents" "$ntracks" "$(grep "Events only time:" $gemc_log | cut -d':' -f3 | cut -d' ' -f2)" >$log_file

echo
cat $log_file
echo
