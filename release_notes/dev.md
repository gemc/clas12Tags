# Release notes


- RG-D Flag Assembly geometry and variations (Lamiaa) 
- Added MIE scattering to api and source code (Connor Pecar)
- RICH hit process: PMT quantum efficiencies (Connor Pecar)
- Material database updated with MIE scattering entries (Connor Pecar)
- Updated CAD volumes for RICH, with variations default, rga_fall2018 and rgc_summer2022 (Connor Pecar)
- Alert hit process improvements (M. Paolone and fizikci0147)
- RTPC hit process improvements (YuchunHung)
- Fixed CND lightguide lengths and sensitivity/hit type in cndUpstrem (Tyler Kutz)
- added checking parameter files in GEMC_DATA_DIR, useful for sharing parameters with reconstruction
- Tungsten material update to beamline_W instead of pure W
- FMT Overlaps fix (#237 fixed)
- Removed duplicated CAD target aluminum windows
- Added beamline components and adjusted vacuum line downstream of the torus, see CLAS Note 2024-006
- Removed DSS volumes and vacuum line from PRODUCTION cuts in clas12-config/gemc/dev
- Significant cleanup on unused geometry files. Note: if someone is still used, please PR the re-activation in gemc/detectors
- RGE double target implementation (Antonio Radic)
- Remove FC (forward carriage) volume, not necessary
- Added WF:10 hipo bank, following Nathan's proposal: https://code.jlab.org/baltzell/clas12-wf/-/blob/main/README.md 
- DC Geometry changes by Raffaella (in progress)
- Torus + Shielding beamline CAD geometry (in progress) 
- Several issues with RG-F target #236 (in progress)




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
