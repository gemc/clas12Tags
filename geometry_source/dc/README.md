# DC Configurations

The first CLAS12 Run was 3029. However we never changed anything in the DC configuration, 
so we use Run 11 for all runs.

| variation    | SQL / CCDB Run | 
|--------------|----------------|
| default      | 11             | 





To build the geometry:

````./dc.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py dc__geometry_default.txt      ../../clas12.sqlite dc  11 default
````


<br/>

---
