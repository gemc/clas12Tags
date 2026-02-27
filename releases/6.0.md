Based on [Coatjava Release](https://github.com/JeffersonLab/coatjava/releases) 13.7.1

# Release notes

This is an upgrade to the meson build system, that replaces scons:

- the scons_bm repository no longer needed
- the mlibrary codes are integrated in the main code, mlibrary repo is no longer needed
- ccdb and hipo are compiled as meson subprojects
- assimp, needed for cad imports, is compiled as meson subproject
- reduces ependencies to geant4 (clhep, xerces-c) only. 
  These can be users installations or coming from g4install
- geant4 version updated from 10.7.4 to the latest (11.4.0)
- g4install modules are used instead of ceInstall modules
- updated installation uses `-prefix` for installation location



 # Environment on ifarm / cvmfs

```console
module use /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/sw/modulefiles 
module load clas12
module switch gemc/6.0
gemc -v 
```