#!/usr/bin/env zsh

runs=(11 3029 4763)
variations=(default
			rga_spring2018_mc
			rga_fall2018_mc
			rga_spring2019_mc
			rgb_fall2019_mc
			rgb_spring2019_mc
			rgc_summer2022_mc
			rgf_spring2020_mc
			rgm_fall2021_mc)


echo "| Run |"
echo "| --- |"
for run in $=runs; do
	echo "| $run |"
done

echo
echo "<br/>"
echo

echo "| Variation |"
echo "| --- |"
for variation in $=variations; do
	echo "| $variation |"
done