# Run Configurations

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| original       | 11             | 
| rga_spring2018 | 3029           | 
| rga_fall2018   | 4763           | 
| rgb_spring2019   | 4763           | 
| rgb_winter2020 | 4763           | 
| rga_fall2019   | 4763           | 

To build the geometry:

````./ltcc.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../clas12.sqlite database

## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py htcc__geometry_original.txt       ../clas12.sqlite htcc  11   default
$GEMC/api/perl/db_compare.py htcc__geometry_rga_spring2018.txt ../clas12.sqlite htcc  3029 default
$GEMC/api/perl/db_compare.py htcc__geometry_rga_fall2018.txt   ../clas12.sqlite htcc  4763 default
````

<br/>

---

## GEMC Output comparison

Run 11:

```
gemc -USE_GUI=0 htcc_sqlite.gcard       -N=10 -OUTPUT="hipo, sql_11.hipo" -RANDOM=123 -RUNNO=11  
gemc -USE_GUI=0 htcc_text_original.gcard -N=10 -OUTPUT="hipo, txt_11.hipo" -RANDOM=123 -RUNNO=11  
```

Run 3029:

```
gemc -USE_GUI=0 htcc_sqlite.gcard              -N=10 -OUTPUT="hipo, sql_3029.hipo" -RANDOM=123 -RUNNO=3029
gemc -USE_GUI=0 htcc_text_rga_spring2018.gcard -N=10 -OUTPUT="hipo, txt_3029.hipo" -RANDOM=123 -RUNNO=3029
```

Run 4763:

```
gemc -USE_GUI=0 htcc_sqlite.gcard            -N=10 -OUTPUT="hipo, sql_4763.hipo" -RANDOM=123 -RUNNO=4763
gemc -USE_GUI=0 htcc_text_rga_fall2018.gcard -N=10 -OUTPUT="hipo, txt_4763.hipo" -RANDOM=123 -RUNNO=4763
```

Then compare the two hipo files with hipo-utils (upcoming comparison by Gagik)



CLAS12 LTCC README
------------------


TODO: Addfocal point spheres for debugging purposes


The geometry consists of 36 elliptical mirrors, 36 hyperbolic mirrors
and 36 PMTs.

The parameters are created by the mirrors.C macro.

In MYSQL mode, before building the geometry one must
upload the parameters onto the DB.

The commands to build the geometry, banks, hit defs
and materials are:

upload_parameters.pl config.dat   < only for MYSQL factory

./ltcc.pl config.dat



CAD Notes:
- The frame model is from sector 2. It is rotated in cad.gxml to sector 3.
- The nose model is from sector 1. It is rotated in cad.gxml to sector 2.
