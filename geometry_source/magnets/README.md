# CLAS12 Magnets


The solenoid is created using Geant4 native volumes. 
The torus magnets has a CAD model that is imported in gemc and a Geant4 native volumes version as well.


# Run Configurations

Torus has only 'default'. Soleinoid has 'default', 'rga_spring2018' and 'rga_fall2018' due to the shifts in the solenoid position.

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| default          | 11             | 
| rga_spring2018   | 3029           | 
| rga_fall2018     | 4763           | 

To build the geometry:

./magnets.pl config.dat


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py torus__geometry_default.txt           ../../clas12.sqlite torus     11   default
$GEMC/api/perl/db_compare.py solenoid__geometry_default.txt        ../../clas12.sqlite solenoid  11   default
$GEMC/api/perl/db_compare.py solenoid__geometry_rga_spring2018.txt ../../clas12.sqlite solenoid  3029 default
$GEMC/api/perl/db_compare.py solenoid__geometry_rga_fall2018.txt   ../../clas12.sqlite solenoid  4763 default
```