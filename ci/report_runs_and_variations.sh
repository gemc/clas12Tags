#!/usr/bin/env zsh

runs=(11 3029 4763)
geo_variations=(default rga_spring2018 rga_fall2018)

variations=(default
			rga_spring2018_mc
			rga_fall2018_mc
			rga_spring2019_mc
			rgb_fall2019_mc
			rgb_spring2019_mc
			rgc_summer2022_mc
			rgf_spring2020_mc
			rgm_fall2021_mc)


echo "Geometry Variation | Run |"
echo "| --- | --- |"

for i in {1..$#runs}; do
	echo "| $geo_variations[$i] | $runs[$i] |"
done


echo
echo "<br/>"
echo

echo "| Digitization Variation |"
echo "| :---: |"
for variation in $=variations; do
	echo "| $variation |"
done