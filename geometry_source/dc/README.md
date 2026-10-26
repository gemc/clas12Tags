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

## Consolidated CAD copies

Upcoming in the next release: ten region-1 back/support copies are part of the native `dc` geometry.
The separate copy bank is retired. Default native geometry has 64 rows; DDVCS TEXT has 70. Load the
two shared source meshes through `dc_cad`, giving 66 or 72 physical volumes in total.
Both TEXT and SQLite cards load just the native detector and CAD source factory.

GEMC3 publishes native geometry, both CAD sources, and all copies in one SQLite `dc` system. Its survey
run keys reuse the default chambers and retain all twelve CAD placements; DDVCS keeps its extra shields.
Mesh bytes, openings, materials, positions, and rotations are unchanged. Duplicate database copy rows
are removed; repeated generation writes each named placement once.
