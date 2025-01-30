# BST Configurations

The first CLAS12 Run was 3029. However we never changed anything in the BST configuration, 
so we use Run 11 for all runs. TODO: we still waiting on the shifts incorporations in the geometry service

| variation    | SQL / CCDB Run | 
|--------------|----------------|
| default      | 11             | 


# Geometry

The geometry consists of 3(4) barrela of modules, 
each with 3 silicon sensors.


To build the geometry:

````./bst.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../clas12.sqlite database


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py bst__geometry_default.txt      ../clas12.sqlite bst  11   default
````

<br/>

---
