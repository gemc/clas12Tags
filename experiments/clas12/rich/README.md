# CLAS12 RICH gemc geometry

RICH geometry constructed as a combination of stl (stored in coatjava) and geant4 volumes.

STL (generated in CLAS12 reference frame for sector 4, rotate 180*deg around z for sector1):
RICH_s*: mother volume (original now edited to properly contain all optical equipment)
Layer 20*: aerogel tiles
Layer 30*: planar mirrors
Additional material budget: mirror support, wrapping, etc.

geant4 volumes:
PMTs and spherical Mirrors

Execute with
./rich.pl config.dat
($COATJAVA must be set)

Generates three configurations:
	  - default: RICH in sector 1 and sector 4, nominal positions
	  - rga_fall2018: RICH in sector 1, +5cm shift in z
	  - rgc_summer2022: RICH in sector 1 and sector 4, +5cm shift in z
Cad and geometry files are imported in gcard as:
        <detector name="rich"         factory="TEXT" variation="default"/>
        <detector name ="cad_default/"    factory="CAD"/>

 