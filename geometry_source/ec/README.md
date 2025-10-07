# Run Configurations

The first CLAS12 Run was 3029. Historically we have been using the 'rga_fall2018' variation that start with Run 4763.
Here we use Run 3029 to apply rga_fall2018 also to rga_spring2018.

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| default        | 11             | 
| rga_spring2018 | 3029           | 




To build the geometry:

````./ec.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py ec__geometry_default.txt        ../../clas12.sqlite ec  11   default
$GEMC/api/perl/db_compare.py ec__geometry_rga_spring2018.txt ../../clas12.sqlite ec  3029 default
````

<br/>

---


