#!/usr/bin/env zsh


die_with_code () {
  # Usage:
  #   some_command ... ; die_with_code /path/to/log
  #   some_command ... ; die_with_code /path/to/log "extra message"
  #   die_with_code /path/to/log "msg" 42   # explicit code override (optional)
  #
  # Behavior:
  #   - If last exit code is 0: return 0 (do nothing)
  #   - Otherwise: print error + code, print log (if readable), exit with code

  local log_file="${1:-}"
  local extra_msg="${2:-}"
  local code

  # Optional explicit code override as 3rd arg; otherwise take $?
  if [[ -n "${3:-}" ]]; then
    code="$3"
  else
    code="$?"
  fi

  # If success, do nothing
  (( code == 0 )) && return 0

  # Error header
  if [[ -n "$extra_msg" ]]; then
    print -u2 -- "ERROR: ${extra_msg} (exit code: ${code})"
  else
    print -u2 -- "ERROR: command failed (exit code: ${code})"
  fi

  # Dump log if provided
  if [[ -n "$log_file" ]]; then
    if [[ -r "$log_file" ]]; then
      print -u2 -- "----- BEGIN LOG: $log_file -----"
      cat -- "$log_file" >&2
      print -u2 -- "----- END LOG: $log_file -----"
    else
      print -u2 -- "NOTE: log file not readable: $log_file"
    fi
  fi

  exit "$code"
}

DetectorDirNotExisting() {
	echo "System directory: $system not existing"
	exit 3
}

log_gemc_info() {
	echo
	echo
	echo "========================================"
	echo "============= log_gemc_info ============"
	echo "========================================"
	echo
	echo "\n > GCard: $gcard"
	echo " > GEMC: $GEMC top level content:\n\n $(ls -l $GEMC/) \n"
	# if GEMC_DATA_DIR different from GEMC, then print it
	if [[ $GEMC_DATA_DIR != $GEMC ]]; then
		echo " > GEMC_DATA_DIR: $GEMC_DATA_DIR top level content:\n\n $(ls -l $GEMC_DATA_DIR/) \n"
	else
		echo " > GEMC_DATA_DIR is the same as GEMC"
	fi

	echo " > gemc: $(which gemc) "
	echo "   Compiled on $(date)"
	echo "   Instrospection: $(gemc --version | grep -v Connecting | grep -v RTPC)"
	echo
	echo " Java version:" $(java -version) $(which java)
    echo " JAVA_HOME=${JAVA_HOME:-<unset>}"
    echo " Groovy version: " $(groovy -version)
	echo
	echo "========================================"
	echo "========================================"
	echo "========================================"
	echo
	echo
}

# returns runs to test
runs_for_system() {
	rgm_runs="15016 15043 15108 15165 15178 15318 15356 15434 15458 15534 15566 15637 15643 15671 15732 15733 15734"
	rge_runs="20035 20041 20070 20074 20131 20177 20232 20269 20282 20331 20435 20494 20506 20507 20508 20520"
	rgl_runs="21000 21001 21002 21003"
	rgd_runs="18347 18372 18560 18660 18874 19061 18339 18369 18400 18440 18756 18796 18316 18399 19060 18305 18318 18419 18528 18644 18764 18851 19021"

	if [[ $system == "ec" || $system == "pcal" || $system == "ftof" ]]; then
		echo "11 3029"
	elif [[ $system == "dc" || $system == "alert" ]]; then
		echo "11"
	elif [[ $system == "bst" ]]; then
		echo "11 20000"
	elif [[ $system == "htcc" || $system == "ctof" || $system == "cnd" || $system == "magnets" ]]; then
		echo "11 3029 4763"
	elif [[ $system == "micromegas" ]]; then
		echo "11 11620 15016"
	elif [[ $system == "ltcc" ]]; then
		echo "11 3029 4763 6150 11323 15016"
	elif [[ $system == "rich" ]]; then
		echo "11 3029 16043"
	elif [[ $system == "ft" ]]; then
		echo "11 5874 6150 11620 16043 20000"
	elif [[ $system == "beamline" ]]; then
		echo "11 5874 6150 11620 16043 16843 20000 21000"
	elif [[ $system == "magnets" ]]; then
		echo "11 3029 4763"
	elif [[ $system == "targets" ]]; then
		echo "11 3029 4763 6150 6608 11093 $rgm_runs $rgd_runs $rge_runs $rgl_runs"
	fi
}

variations_for_run_and_system()  {
	if [[ $1 == "11" ]]; then
		echo "default"
	elif [[ $1 == "3029" ]]; then
		echo "rga_spring2018"
	elif [[ $1 == "4760" ]]; then
		echo "rga_fall2018"
	elif [[ $1 == "5674" ]]; then
		echo "rgk_fall2018"
	elif [[ $1 == "5874" ]]; then
		echo "rgk_winter2018"
	elif [[ $1 == "6141" ]]; then
		echo "rgb_spring2019"
	elif [[ $1 == "6607" ]]; then
		echo "rga_spring2019"
	elif [[ $1 == "11014" ]]; then
		echo "rgb_fall2019"
	elif [[ $1 == "11323" ]]; then
		echo "rgb_spring2020"
	elif [[ $1 == "11607" ]]; then
		echo "rgf_spring2020"
	elif [[ $1 == "12321" ]]; then
		echo "rgf_summer2020"
	elif [[ $1 == "15016" || $1 == "15534" || $1 == "15628" ]]; then
		echo "rgm_fall2021_H"
	elif [[ $1 == "15043" || $1 == "15434" || $1 == "15566" ]]; then
		echo "rgm_fall2021_D"
	elif [[ $1 == "15108" || $1 == "15458" ]]; then
		echo "rgm_fall2021_He"
	elif [[ $1 == "15643" || $1 == "15733" ]]; then
		echo "rgm_fall2021_C_S"
	elif [[ $1 == "15766" || $1 == "15778" ]]; then
		echo "rgm_fall2021_C_L"
	elif [[ $1 == "15671" || $1 == "15734" || $1 == "15789" ]]; then
		echo "rgm_fall2021_Ar"
	elif [[ $1 == "15178" ]]; then
		echo "rgm_fall2021_Cx4"
	elif [[ $1 == "15356" || $1 == "15829" ]]; then
		echo "rgm_fall2021_Ca"
	elif [[ $1 == "15318" ]]; then
		echo "rgm_fall2021_Snx4"
	elif [[ $1 == "15804" ]]; then
		echo "rgm_fall2021_Sn_L"
	elif [[ $1 == "16000" ]]; then
		echo "rgc_summer2022"
	elif [[ $1 == "16843" ]]; then
		echo "rgc_fall2022"
	elif [[ $1 == "17471" ]]; then
		echo "rgc_spring2023"
	elif [[ $1 == "18347" || $1 == "18372"  || $1 == "18560" || $1 == "18660" || $1 == "18874"  || $1 == "19061" ]]; then
		echo "rgd_fall2023_CuSn"
	elif [[ $1 == "18339" || $1 == "18369"  || $1 == "18400" || $1 == "18440" || $1 == "18440"  || $1 == "18440" ]]; then
		echo "rgd_fall2023_CxC"
	elif [[ $1 == "18305" || $1 == "18318"  || $1 == "18419" || $1 == "18528" || $1 == "18644"  || $1 == "18764" || $1 == "18851"  || $1 == "19021" ]]; then
		echo "rgd_fall2023_lD2"
	elif [[ $1 == "18316" || $1 == "18399"  || $1 == "19060" ]]; then
		echo "rgd_fall2023_empty"
	elif [[ $1 == "19200" ]]; then
		echo "rgk_fall2023"
	elif [[ $1 == "19300" ]]; then
		echo "rgk_spring2024"
	elif [[ $1 == "20070" ]]; then
		echo "rge_spring2024_Empty_C"
	elif [[ $1 == "20035" || $1 == "20507" ]]; then
		echo "rge_spring2024_Empty_Empty"
	elif [[ $1 == "20269" ]]; then
		echo "rge_spring2024_Empty_Pb"
	elif [[ $1 == "20435" ]]; then
		echo "rge_spring2024_LD2_Al"
	elif [[ $1 == "20021" || $1 == "20131"  || $1 == "20508" ]]; then
		echo "rge_spring2024_LD2_C"
	elif [[ $1 == "20177" ]]; then
		echo "rge_spring2024_LD2_Cu"
	elif [[ $1 == "20041" || $1 == "20074"  || $1 == "20232" || $1 == "20282" || $1 == "20494"  || $1 == "20520" ]]; then
		echo "rge_spring2024_LD2_Pb"
	elif [[ $1 == "20331" ]]; then
		echo "rge_spring2024_LD2_Sn"
	elif [[ $1 == "21000" ]]; then
		echo "rgl_spring2025"
	elif [[ $1 == "21001" ]]; then
		echo "rgl_spring2025_H2"
	elif [[ $1 == "21002" ]]; then
		echo "rgl_spring2025_D2"
	elif [[ $1 == "21003" ]]; then
		echo "rgl_spring2025_He"
	elif [[ $1 == "21003" ]]; then
		echo "rgl_spring2025"
	fi
}

# show environment
# export

# if we are in the docker container, we need to load the modules
if [[ -z "${AUTOBUILD}" ]]; then
	echo "\nNot in container, loading gemc/dev - assuing we are on a mac with homebrew modules"
	source /opt/homebrew/opt/modules/init/zsh
	module purge
	module load gemc/dev
	echo
else
	echo "\nIn docker container, sourcing local setup and loading gemc, ccdb and hipo"
	if [[ -n "${GITHUB_WORKFLOW}" ]]; then
		echo "GITHUB_WORKFLOW: ${GITHUB_WORKFLOW}"
	fi
	source /etc/profile.d/localSetup.sh
	module switch gemc/dev

	module load hipo
	module load ccdb
	echo

	# recent versions of Git refuse to touch a repository whose on-disk owner
	# doesn’t match the UID that is running the command
	# mark the workspace (and any nested path) as safe
	echo "Marking workspace as safe for Git"
	git config --global --add safe.directory '*'

	export GEMC=$(pwd)
	export GEMC_DATA_DIR=$GEMC
	echo "Setting GEMC and GEMC_DATA_DIR to this directory: $GEMC"
	export PATH=$GEMC/bin:$PATH
	export ARTIFACT_DIR=/cvmfs/oasis.opensciencegrid.org/jlab/geant4

fi
