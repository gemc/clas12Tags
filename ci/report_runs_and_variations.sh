#!/usr/bin/env zsh

source ci/env.sh

# Enable associative arrays
typeset -A geo_runs

# Populate the associative array
geo_runs=(
    [default]=11
    [rga_spring2018]=3029
    [rga_fall2018]=4763
    [rga_spring2019]=6608
    [rgb_spring2019]=6150
    [rgb_fall2019]=11093
    [rgb_winter2020]=11323
    [rgc_summer2022]=16043
    [rgc_fall2022]=16843
    [rgc_winter2023]=17471
    [rgd_fall2023]=18305
    [rge_spring2024]=20000
    [rgf_spring2020]=11620
    [rgf_summer2020]=12389
    [rgk_fall2018]=5674
    [rgk_winter2018]=5874
    [rgk_winter2022]=19200
    [rgk_spring2024]=19300
    [rgl_spring2025]=21000
    [rgm_winter2021]=15016

)

# Array of digitization variations, obtained locally with:
# awk -F'value="' '/DIGITIZATION_VARIATION/ {split($2, a, "\""); print a[1]}' /opt/projects/clas12-config/gemc/dev/*  | sort -u
dvariations=(
	default
	rga_fall2018_mc
	rga_spring2018_mc
	rga_spring2019_mc
	rgb_fall2019_mc
	rgb_spring2019_mc
	rgc_summer2022_mc
	rgf_spring2020_mc
	rgm_fall2021_mc
)

# Print header for geometry variations
echo "Geometry Variation | Run |"
echo "| --- | --- |"

# Iterate over the keys in the associative array
for geo in "${(@k)geo_runs}"; do
    echo "| $geo | ${geo_runs[$geo]} |"
done

echo
echo "<br/>"
echo

# Print header for digitization variations
echo "| Digitization Variations |"
echo "| --- |"

for variation in $=dvariations; do
    echo "| $variation |"
done
