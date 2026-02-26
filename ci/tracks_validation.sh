#!/usr/bin/env zsh

# Purpose: runs gemc using all the gcards in clas12-config dev branch

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-almalinux94 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/tracks_validation.sh

source ci/env.sh
target_vz='-3.0*cm'
gcard="clas12-config/gemc/dev/clas12-default.gcard"
lund_type=electronprotonC

Help() {
	# Display Help
	echo
	echo "Syntax: tracks_validation.sh  [-h|g|l]"
	echo
	echo "Options:"
	echo
	echo "-h: Print this Help."
	echo "-g: gcard base to be used. Default: $gcard"
	echo "-l: lund type. Default: $lund_type"
	echo "    Possible choices:"
	echo "     - electronproton"
	echo "     - electrongamma"
	echo "     - electronprotonC"
	echo "     - electronneutronC"
	echo "     - electronFTpion"
	echo
}

while getopts ":hg:l:" option; do
	case $option in
		h)
			Help
			exit
			;;
		g)
			gcard="clas12-config/gemc/dev/$OPTARG.gcard"
			;;
		l)
			lund_type="$OPTARG"
			;;
		\?)    # Invalid option
			echo "Error: Invalid option"
			exit 1
			;;
	esac
done


[[ -d clas12-config ]] && echo clas12-config exist || git clone -b dev https://github.com/JeffersonLab/clas12-config
echo " > Gcard: $gcard\n"

if [[ ! -f "$gcard" ]]; then
	echo "Gcard: $gcard not existing"
	Help
	exit 3
fi


logs_dir=/root/logs
if [[ -z "${AUTOBUILD}" ]]; then
	logs_dir="$(pwd)/logs"
	echo "\nNot in container, logs are in this directory: $logs_dir"
	rm -rf $logs_dir
fi

mkdir -p $logs_dir
log_file=$logs_dir/"$lund_type"_tracks.log
gen_log=$logs_dir/gen.log
gemc_log=$logs_dir/gemc.log
recon_log=$logs_dir/recon.log
efficiency_log=$logs_dir/eff.log

# generate events based on lund type

list_file=geometry_source/coatjava_src/validation/advanced-tests/src/eb/scripts/list.txt
gen_script=geometry_source/coatjava_src/validation/advanced-tests/src/eb/scripts/gen.sh
input=$(grep "$lund_type " $list_file | sed 's/.* -pid/-pid/' )
nevents=20
event_lund_file="$lund_type.txt"
gemc_output="gemc_$lund_type.hipo"

print -r -- "Running command:"
print -r -- "> $gen_script" "${input[@]}"
"$gen_script" "${input[@]}" 2>&1 | tee $gen_log  >/dev/null
die_with_code "$gen_log" "generator failed" $?
echo

# run gemc using the generated events
typeset -a gemc_opts
gemc_opts=(
  -INPUT_GEN_FILE="lund, ${event_lund_file}"
  -NGENP=50
  -USE_GUI=0
  -N="${nevents}"
  -PRINT_EVENT=10
  -GEN_VERBOSITY=10
  -SAVE_ALL_MOTHERS=1
  -SKIPREJECTEDHITS=1
  -INTEGRATEDRAW="*"
  -OUTPUT="hipo, $gemc_output"
)

gemc_bin=$(which gemc)

print -r -- "Running command:"
print -r -- "> $gemc_bin" "${gemc_opts[@]}" "$gcard"

"$gemc_bin" "${gemc_opts[@]}" "$gcard" | sed '/G4Exception-START/,/G4Exception-END/d' 2>&1 | tee "${gemc_log}"  >/dev/null
die_with_code "$gemc_log" "gemc failed" $?
echo

# exit if it's not found
evt_only_time=$(grep "Events only time:" $gemc_log | cut -d':' -f3 | cut -d' ' -f2)
if [[ -z $evt_only_time ]]; then
	echo "Error: Events only time not found in gemc log"
	echo "Log:"
	cat $gemc_log
	exit 4
fi

printf '%s %s %s\n' "$nevents" "$ntracks" "$evt_only_time" > $log_file

# run reconstruction
export COATJAVA=$(pwd)/geometry_source/coatjava
yaml="clas12-config/coatjava/11.1.0/clas12-default.yaml"
recon_output="recon_$lund_type.hipo"
recon_bin="$COATJAVA/bin/recon-util"
typeset -a recon_opts
recon_opts=(
	-l FINE
	-i "$gemc_output"
	-o "$recon_output"
	-y "$yaml"
)

rm "$recon_output"
print -r -- "Running command:"
print -r -- "> $recon_bin" "${recon_opts[@]}"
"$recon_bin" "${recon_opts[@]}"  2>&1 | tee $recon_log >/dev/null
die_with_code "$recon_log" "reconstruction failed" $?
echo

# show results
print -r -- "Running command:"
print -r -- "> $COATJAVA/bin/trutheff" "$recon_output"
"$COATJAVA/bin/trutheff" "$recon_output"  2>&1 | tee $efficiency_log  >/dev/null
die_with_code "$efficiency_log" "trutheff failed" $?
