# Simulation of RICH  

The RICH_sector 4 is a combination of STL volumes (stored in coatjava) and G4 native volumes.

Aerogel Tiles (indicaded by layer 200) and passive material are STL file generated in the reference frame of the center of CLAS12, for this one these volumes can apply only at the rich of sector 4.

PMTs and spherical Mirrors are generated starting from G4 native volumes. 

Scripts executed with
'perl rich_sector4.pl config.dat'

Environment variable 'COATJAVA' must be set, pointing to coatjava>6b.3.0

