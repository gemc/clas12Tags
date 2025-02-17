# Geometry

The geometry consists of:
LeadTungsten calorimeter 
Scintillation hodoscope
Micromegas tracker 



# Run Configurations

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| default          | 11             | 
| rgk_winter2018   | 5874           | 
| rgb_spring2019   | 6150           | 
| rgf_spring2020   | 11620          |
| rgc_summer2022   | 16043          |
| rge_spring2024   | 20000          |

To build the geometry:

./ft.pl config.dat




## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py ft__geometry_default.txt        ../../clas12.sqlite ft  11   default
$GEMC/api/perl/db_compare.py ft__geometry_rgk_winter2018.txt ../../clas12.sqlite ft  5874 default
$GEMC/api/perl/db_compare.py ft__geometry_rgb_spring2019.txt ../../clas12.sqlite ft  6150 default
$GEMC/api/perl/db_compare.py ft__geometry_rgf_spring2020.txt ../../clas12.sqlite ft 11620 default
$GEMC/api/perl/db_compare.py ft__geometry_rgc_summer2022.txt ../../clas12.sqlite ft 16043 default
$GEMC/api/perl/db_compare.py ft__geometry_rge_spring2024.txt ../../clas12.sqlite ft 20000 default

````
