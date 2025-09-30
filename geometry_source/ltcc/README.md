# Geometry

The geometry consists of 36 elliptical mirrors, 36 hyperbolic mirrors
and 36 PMTs.

The parameters are created by the mirrors.C macro.

# Run Configurations

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| default        | 11             | 
| rga_spring2018 | 3029           | 
| rga_fall2018   | 4763           | 
| rgb_spring2019 | 6150           | 
| rgb_winter2020 | 11323          | 
| rgm_fall2021_H | 15016          | 

To build the geometry:

````./ltcc.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database

## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py ltcc__geometry_default.txt        ../../clas12.sqlite ltcc  11   default
$GEMC/api/perl/db_compare.py ltcc__geometry_rga_spring2018.txt ../../clas12.sqlite ltcc  3029 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rga_fall2018.txt   ../../clas12.sqlite ltcc  4763 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rgb_spring2019.txt ../../clas12.sqlite ltcc  6150 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rgb_winter2020.txt ../../clas12.sqlite ltcc 11323 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rgm_rgm_fall2021_H.txt ../../clas12.sqlite ltcc 15016 default
````

<br/>

---


TODO:

- Add focal point spheres for debugging purposes
- Generalize material and presence in a single file and use it for all LTCC components

CAD Notes:

- The frame model is from sector 2. It is rotated in cad.gxml to sector 3.
- The nose model is from sector 1. It is rotated in cad.gxml to sector 2.
