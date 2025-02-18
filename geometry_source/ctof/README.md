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
2. add detector run entries to the ../../clas12.sqlite database


## Geometry comparison:

Not applicable to CTOF as the geant4 geometry is empty.

<br/>

