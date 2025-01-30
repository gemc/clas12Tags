# Run Configurations

The first CLAS12 Run was 3029. Historically we have been using the 'rga_fall2018' variation that start with Run 4763.
Here we use Run 3029 to apply rga_fall2018 also to rga_spring2018.

| variation    | SQL / CCDB Run | 
|--------------|----------------|
| default      | 11             | 
| rga_fall2018 | 3029           | 




To build the geometry:

````./pcal.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../clas12.sqlite database


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py pcal__geometry_default.txt      ../clas12.sqlite pcal  11   default
$GEMC/api/perl/db_compare.py pcal__geometry_rga_fall2018.txt ../clas12.sqlite pcal  3029 default
````

<br/>

---




## GEMC Output comparison

Run 11:

```
gemc -USE_GUI=0 pcal_sqlite.gcard       -N=10 -OUTPUT="hipo, sql_11.hipo" -RANDOM=123 -RUNNO=11  
gemc -USE_GUI=0 pcal_text_default.gcard -N=10 -OUTPUT="hipo, txt_11.hipo" -RANDOM=123 -RUNNO=11  
```

Run 3029:

```
gemc -USE_GUI=0 pcal_sqlite.gcard            -N=10 -OUTPUT="hipo, sql_3029.hipo" -RANDOM=123 -RUNNO=3029
gemc -USE_GUI=0 pcal_text_rga_fall2018.gcard -N=10 -OUTPUT="hipo, txt_3029.hipo" -RANDOM=123 -RUNNO=3029
```

Then compare the two hipo files with hipo-utils (upcoming comparison by Gagik)
