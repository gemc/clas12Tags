# CLAS12 Beamline



# Run Configurations

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| default          | 11             | 
| rgk_winter2018   | 5874           | 
| rgb_spring2019   | 6150           | 
| rgf_spring2020   | 11620          |
| rgc_summer2022   | 16043          |
| rgc_fall2022     | 16843          |
| rge_spring2024   | 20000          |

To build the geometry:

./beamline.pl config.dat




## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py bealine__geometry_default.txt        ../../clas12.sqlite bealine  11   default
$GEMC/api/perl/db_compare.py bealine__geometry_rgk_winter2018.txt ../../clas12.sqlite bealine  5874 default
$GEMC/api/perl/db_compare.py bealine__geometry_rgb_spring2019.txt ../../clas12.sqlite bealine  6150 default
$GEMC/api/perl/db_compare.py bealine__geometry_rgf_spring2020.txt ../../clas12.sqlite bealine 11620 default
$GEMC/api/perl/db_compare.py bealine__geometry_rgc_summer2022.txt ../../clas12.sqlite bealine 16043 default
$GEMC/api/perl/db_compare.py bealine__geometry_rgc_fall2022.txt   ../../clas12.sqlite bealine 16843 default
$GEMC/api/perl/db_compare.py bealine__geometry_rge_spring2024.txt ../../clas12.sqlite bealine 20000 default

````
