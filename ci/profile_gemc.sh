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

nevents=60
mkdir -p /root/logs
gemc_log=/root/logs/gemc.log
callgrind_out=/root/logs/callgrind.out.$ntracks

# if $ntracks is clasdis then use clasdis lund file
if [[ $ntracks == "clasdis_all"  ]]; then
	nevents=20
	cp ci/generated_events/"$ntracks".dat events.dat
	echo "Using $nevents events from lund file generated with clasdis --trig 200 --docker"
else
	lund_file="ci/generated_events/"$ntracks"_tracks.dat"
	echo "Generating file events.dat with $nevents events from lund file: $lund_file"
	./ci/generated_events/randomize_particles.py --nevents $nevents -o events.dat --theta-min 7 --theta-max 120 --seed 123 $lund_file
fi

# same options as on OSG
echo "Running valgrind on $(which gemc) with options:  -INPUT_GEN_FILE=\"lund, events.dat\" -USE_GUI=0 -N=$nevents -PRINT_EVENT=10 -GEN_VERBOSITY=10 $gcard"
# Cache and branch simulation add the miss counts the CEst (cycle-estimation) formula needs, so
# qcachegrind and ci/profile_summary.py can report estimated cycles instead of raw instruction reads.
valgrind --tool=callgrind --callgrind-out-file="$callgrind_out" \
	--dump-instr=yes --collect-jumps=yes --skip-plt=yes --cache-sim=yes --branch-sim=yes $(which gemc) \
	-INPUT_GEN_FILE="lund, events.dat"    -USE_GUI=0 -N=$nevents -PRINT_EVENT=10 -GEN_VERBOSITY=10  -RANDOMIZE_LUND_VZ='-1.94*cm, 2.5*cm, reset ' \
	-BEAM_SPOT='0.0*mm, 0.0*mm, 0.0*mm, 0.0*mm, 0*deg, reset '   -RASTER_VERTEX='0.0*cm, 0.0*cm, reset ' \
	-SCALE_FIELD='binary_torus, -1.00' -SCALE_FIELD='binary_solenoid, -1.00' -INTEGRATEDRAW='*' $gcard >$gemc_log
exitCode=$?

if [[ $exitCode != 0 ]]; then
	echo exiting with gemc exitCode: $exitCode
	exit $exitCode
fi

# Per-detector CEst category table next to the callgrind file (best effort: needs callgrind_annotate).
summary_md=/root/logs/summary.$ntracks.md
if command -v callgrind_annotate >/dev/null 2>&1; then
	echo "Writing category summary to $summary_md"
	python3 ci/profile_summary.py "$callgrind_out" --title "$ntracks tracks" > "$summary_md" || \
		echo "Category summary generation failed; the callgrind file is still available."
else
	echo "callgrind_annotate not found; skipping the category summary."
fi

# Show the table in this job's own summary too, so it does not depend on the artifact round-trip.
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
	if [[ -s "$summary_md" ]]; then
		cat "$summary_md" >> "$GITHUB_STEP_SUMMARY"
	else
		echo "_No category table was produced for $ntracks (see the job log)._" >> "$GITHUB_STEP_SUMMARY"
	fi
fi

echo
echo "Category summary:"
cat "$summary_md" 2>/dev/null || echo "  (none)"
ls -l /root/logs
echo
