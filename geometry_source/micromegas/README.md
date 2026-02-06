# Geometry 

The geometry consists of central barrel (BMT) and a forward one (FMT) of micromegas detectors.

# Run Configurations

| variation        | SQL / CCDB Run | Configuration                                     |
|------------------|----------------|---------------------------------------------------|
| default          | 11             | BMT, 6 FMT layers                                 |
| rga_spring2018   | 3029           | BMT, 6 FMT layers                                 |
| rga_fall2018     | 4763           | BMT, no FMT                                       |
| rgf_spring2020   | 11620          | no BMT, 3 FMT layers, slim                        |
| rgm_fall2021_H   | 15016          | BMT, 3 FMT layers, slim                           |
| rgc_summer2022   | 16000          | BMT, no FMT                                       |
| rgd_fall2023     | 18305          | BMT, 3 FMT layers, slim                           |
| rgk_fall2023     | 19200          | BMT, no FMT                                       |
| rge_spring2024   | 20000          | BMT, 3 FMT layers, slim                           |
| rgl_spring2025   | 21000          | no BMT, no FMT                                    |
| michel_9mmcopper | 30000          | BMT, 3 FMT layers slim, modified copper thickness |


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
