# Simulation of RICH  

The RICH_sector 4 is a combination of STL volumes and G4 native volumes.

Aerogel Tiles (indicaded by layer 200) and passive material are STL file generated in the reference frame of the center of CLAS12, for this one these volumes can apply only at the rich of sector 4.

PMTs and spherical Mirrors are generated starting from G4 native volumes.


In order to run the perl, you need COATJAVA>6b.3.0 linked to your groovy script since it is needed to have the right RICHGeant4Factory with the respective stl volumes.


