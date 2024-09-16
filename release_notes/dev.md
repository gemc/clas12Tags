# Release notes


- RG-D Flag Assembly geometry and variations (Lamiaa) 
- added MIE scattering to api and source code (Connor)
- material database updated with MIE scattering entries
- RICH hit process: PMT quantum efficiencies (Connor)
- Alert hit process improvements (M. Paolone and fizikci0147)
- RTPC hit process improvements (YuchunHung)
- Fixed CND lightguide lengths and sensitivity/hit type in cndUpstrem (Tyler Kutz)
- added checking parameter files in GEMC_DATA_DIR, useful for sharing parameters with reconstruction
- Tungsten material update to beamline_W instead of pure W
- RGE double target implementation (Antonio Radic and USM Chile) (in progress)
- DC Geometry changes by Raffaella (in progress)
- FMT Overlaps fix (#237 fixed)
- Downstream of the torus beamline CAD geometry implemented (in progress)
- Several issues with RG-F target #236 (in progress)
- Remove FC (forward carriage) volume, not necessary (in progress) 
- Removed duplicated CAD target aluminum windows
- Added beamline components and adjusted vacuum line downstream of the torus, see CLAS Note 


<br/>
<hr/>

 # Environment on ifarm / cvmfs

```
module use /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/sw/modulefiles 
module load clas12
module switch gemc/dev

gemc -v 

  > gemc version: gemc dev

  > Environment:

  > FIELD_DIR: /cvmfs/oasis.opensciencegrid.org/jlab/geant4/noarch/data/magfield
  > GEMC_DATA_DIR: /cvmfs/oasis.opensciencegrid.org/jlab/geant4/1.1/almalinux9-gcc11/clas12Tags/dev
  > G4DATA_DIR: /cvmfs/oasis.opensciencegrid.org/jlab/geant4/1.1/almalinux9-gcc11/geant4/10.7.4/data/Geant4-10.7.4/data
  > G4_VERSION: 10.7.4
  > G4INSTALL: /cvmfs/oasis.opensciencegrid.org/jlab/geant4/1.1/almalinux9-gcc11/geant4/10.7.4

```
