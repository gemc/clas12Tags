# Geometry 

The geometry consists of central barrel (BMT) and a forward one (FMT) of micromegas detectors.

# Run Configurations

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| rga_spring2018   | 3029           | 
| rgf_spring2020   | 11620          | 
| rgm_fall2021_H   | 15016          | 
| michel_9mmcopper | 30000          | 


rga_spring2018:  BMT, 6 FMT layers
rgf_spring2020:  no BMT, 3 FMT layers
rgm_fall2021_H:  BMT, 3 FMT layers

To build the geometry:

````./micromegas.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database



## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py micromegas__geometry_rga_spring2018.txt ../../clas12.sqlite micromegas  3029  default
$GEMC/api/perl/db_compare.py micromegas__geometry_rgf_spring2020.txt ../../clas12.sqlite micromegas  11620 default
$GEMC/api/perl/db_compare.py micromegas__geometry_rgm_fall2021_H.txt ../../clas12.sqlite micromegas  15016 default
````

<br/>

---
