# Geometry 

The Geometry is a modification of the BMT to the layer thicknesses and geometry of the RT for PAC53

# Run Configurations

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| rga_spring2018   | 3029           | 
| rgf_spring2020   | 11620          | 
| rgm_winter2021   | 15016          | 
| michel_9mmcopper | 30000          | 


rga_spring2018:  BMT, 6 FMT layers
rgf_spring2020:  no BMT, 3 FMT layers
rgm_winter2021:  BMT, 3 FMT layers

To build the geometry:

````./RT.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames


<br/>

---
