# EC Configurations

| variation    | Geo SQL Run | CCDB Run Number |
|--------------|-------------|-----------------|
| default      | 11          | NA              |
| rga_fall2018 | 101         | 3306            |

To build the geometry:

````./ec.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add ec run entries to the ../clas12.sqlite database

## Consistency check method 1: compare parameters

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py ec__geometry_default.txt      ../clas12.sqlite ec  11 default
$GEMC/api/perl/db_compare.py ec__geometry_rga_fall2018.txt ../clas12.sqlite ec 101 default
````

<br/>

---

## Consistency check method 2: run gemc with both databases


Run 11:

```
gemc -USE_GUI=0 ec_sqlite.gcard -N=10 -OUTPUT="hipo, sql11.hipo"       -RANDOM=123 -RUNNO=11  
gemc -USE_GUI=0 ec_text_default.gcard -N=10 -OUTPUT="hipo, text_default.hipo" -RANDOM=123 -RUNNO=11  
```

Run 3306:

```
gemc -USE_GUI=0 ec_sqlite.gcard -N=10 -OUTPUT="hipo, sql101.hipo"       -RANDOM=123 -RUNNO=3306
gemc -USE_GUI=0 ec_text_rga_fall2018.gcard -N=10 -OUTPUT="hipo, text_rga_fall2018.hipo" -RANDOM=123 -RUNNO=3306
```

Then compare the two hipo files with hipo-utils (upcoming comparison by Gagik)
