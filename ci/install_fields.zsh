#!/bin/zsh

# Locate the field directory next to the active GEMC installation.
gemc_path=${commands[gemc]}
if [[ -z "$gemc_path" ]]; then
	echo "$red > gemc is not in PATH. Load it with module load gemc. Exiting.$reset"
	exit 1
fi

base_dir="${gemc_path:A:h:h}/fields"
mkdir -p "$base_dir"

# fieds used for data:
# https://github.com/JeffersonLab/clas12-offline-software/blob/development/etc/services/data.yaml
# brepo dir on the CUES: /group/clas/www/clasweb/html/clas12offline/magfield
brepo="https://clasweb.jlab.org/clas12offline/magfield"
maps=(Symm_solenoid_r601_phi1_z1201_13June2018 Symm_torus_r2501_phi16_z251_24Apr2018 Full_torus_r251_phi181_z251_25Jan2021 Full_torus_r251_phi181_z251_03March2020  Full_torus_r251_phi181_z251_08May2018 Full_transsolenoid_x321_y161_z321_March2021_April2024)
for map in $maps; do
  field="$brepo/$map.dat"
	if [ ! -f "$base_dir/$map.dat" ]; then
		echo "$magenta > Downloading $field$reset in $base_dir"
		wget -q -P $base_dir $field
	fi
done
cp $base_dir/Full_transsolenoid_x321_y161_z321_March2021_April2024.dat $base_dir/Full_transsolenoid_x321_y161_z321_April2024.dat

# ASCII files fields
brepo="https://clasweb.jlab.org/12gev/field_maps"
maps=(TorusSymmetric clas12NewSolenoidFieldMap)
for map in $maps; do
  field="$brepo/$map.dat"
	if [ ! -f "$base_dir/$map.dat" ]; then
		echo "$magenta > Downloading $field$reset"
		wget -q -P $base_dir $field
	fi
done

echo " > Fields are installed."
echo
