# Geometry 

The geometry consists of a barrel of 50 scintillators.

# Run Configurations

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| default        | 11             | 
| rga_spring2018 | 3029           | 
| rga_fall2018   | 4763           | 

To build the geometry:

````./ctof.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../clas12.sqlite database



## GEMC Output comparison

Run 11:

```
gemc -USE_GUI=0 ctof_sqlite.gcard       -N=10 -OUTPUT="hipo, sql_11.hipo" -RANDOM=123 -RUNNO=11  
gemc -USE_GUI=0 ctof_text_default.gcard -N=10 -OUTPUT="hipo, txt_11.hipo" -RANDOM=123 -RUNNO=11  
```


<br/>

---