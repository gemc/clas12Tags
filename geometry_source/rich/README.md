# Geometry 

RICH geometry constructed as a combination of stl (stored in coatjava) and geant4 volumes.

STL (generated in CLAS12 reference frame for sector 4, rotate 180*deg around z for sector1):
RICH_s*: mother volume (original now edited to properly contain all optical equipment)
Layer 20*: aerogel tiles
Layer 30*: planar mirrors
Additional material budget: mirror support, wrapping, etc.

geant4 volumes:
PMTs and spherical Mirrors

# Run Configurations

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| default        | 11             | 
| rga_spring2018 | 3029           | 
| rgc_summer2022 | 16043          | 

To build the geometry:

````./rich.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py rich__geometry_default.txt          ../../clas12.sqlite rich  11   default
$GEMC/api/perl/db_compare.py rich__geometry_rga_spring2018.txt   ../../clas12.sqlite rich  3029 default
$GEMC/api/perl/db_compare.py rich__geometry_rgc_summer2022.txt   ../../clas12.sqlite rich  16043 default
````