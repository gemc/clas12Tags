# The clas12Tags repository

### Pull requests

- [![Almalinux Build](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_almalinux.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_almalinux.yml) [![Fedora Build](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_fedora.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_fedora.yml) [![Ubuntu Build](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_ubuntu.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_ubuntu.yml)
- [![Clas12-Config GCards Tests](https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_gcards_test.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_gcards_test.yml)
- [![Coatjava Validation](https://github.com/gemc/clas12Tags/actions/workflows/validation.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/validation.yml)
- [![CodeQL Advanced](https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml)
- [![Ntracks Metrics](https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml)
- [![Local Gcards Tests](https://github.com/gemc/clas12Tags/actions/workflows/local_gcards.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/local_gcards.yml)

### Nightly

- [![Nightly Dev Release](https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml)
- [![Valgrind](https://github.com/gemc/clas12Tags/actions/workflows/profile.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/profile.yml)
- [![Ascii vs Sqlite](https://github.com/gemc/clas12Tags/actions/workflows/txt_sql_comparison.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/txt_sql_comparison.yml)
- [![Clas12-config Dev Main Comparison](https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_dev_main_comparison.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_dev_main_comparison.yml)

## QuickStart

```bash
git clone https://github.com/gemc/clas12Tags
cd clas12Tags
./create_geometry.sh cnd     # build & test the CND detector
```

## Table of Contents
- [Introduction](#introduction)
- [General Information](#general-information)
- [How to create the CLAS12 detector geometry database](#how-to-create-the-clas12-detector-geometry-database)
  - [Pre-requisites](#pre-requisites)
  - [Procedure](#procedure)
    - [Step 1: Clone the repository](#step-1-clone-the-repository)
    - [Step 2: Install coatjava](#step-2-install-coatjava)
    - [Step 3: Build the geometry database](#step-3-build-the-geometry-database)
  - [1. Create and Install the geometry database into the experiments directory](#1-create-and-install-the-geometry-database-into-the-experiments-directory)
  - [2. Debug / test a detector geometry in the geometry_source directory](#2-debug--test-a-detector-geometry-in-the-geometry_source-directory)
- [How compile the source code at JLab](#how-compile-the-source-code-at-jlab)
- [Release workflow](#release-workflow)
  - [Pull requests](#pull-requests)
  - [Run at JLab:](#run-at-jlab)
- [Docker Images](#docker-images)
- [Portal to Off-site farms CLAS12 Simulations](#portal-to-off-site-farms-clas12-simulations)
- [Profiling](#profiling)
  - [Time per track](#time-per-track)
- [Utilities](#utilities)
  - [Changing a material](#changing-a-material)
  - [Removing a detector or a volume](#removing-a-detector-or-a-volume)
- [Citations](#citations)
- [Maurizio Ungaro](#maurizio-ungaro)


## Introduction

The clas12Tags repository is the Geant4 simulation resource for the CLAS12 experiments
at Jefferson Lab, providing:

- The CLAS12 geometry databases, in the form of ASCII and SQLite files.
- The CLAS12 geometry source code. It creates the geometry databases.
- Detectors steering cards (GCARDS) for debugging and testing.
- The GEMC c++ source code and perl API.

The `experiments` directory contains the **latest version of the geometry database 
of the CLAS12 detectors**, built using the **latest tagged version of coatjava**.



<p align="center">
  <img src="clas12.png?raw=true" alt="CLAS12 detector rendering" width="600">
  <br>
  <em>Figure&nbsp;1 — The CLAS12 detector simulation. The electron beam travels left&nbsp;→&nbsp;right.</em>
</p>

## General Information:

- [GEMC Documentation Page](https://gemc.jlab.org/gemc/html/index.html)
- [CLAS12 Discourse Forum: Simulation](https://clas12.discourse.group/c/simulation/9)
- [Clas12-config repository with the various experiments steering cards](https://github.com/JeffersonLab/clas12-config)
- [CLAS12 Software Center Wiki](https://clasweb.jlab.org/wiki/index.php/CLAS12_Software_Center#tab=Communications)
- [CCDB Viewer](https://clasweb.jlab.org/cgi-bin/ccdb/objects)


# How to create the CLAS12 geometry databases

## Pre-requisites

You will need:

- `maven`, `java (openjdk >= 17)` and `groovy` to install and run the coatjava geometry service.
- gemc environment.

The above requirements are met at JLab by loading the usual **clas12 module**, 
then switching to gemc/dev:

```bash
module use /scigroup/cvmfs/hallb/clas12/sw/modulefiles
module load clas12
module switch gemc/dev
```

> [!Caution]
> This will set the environment variables `GEMC` (used by the perl API; `GEMC`/bin added to your path) and 
> `GEMC_DATA_DIR` (used by gemc to find the databases) to the /scigroup location.
> Be careful: 
> 1) If you are testing specific perl API changes, point `GEMC` the cloned clas12Tags directory.
> 2) If you are testing geometry changes using the clas12-config gcards,  
>    point `GEMC_DATA_DIR` the cloned clas12Tags directory.
> 3) If you are testing changes within the geometry_source directory, you do not need to set any  
>    additional variables, as the detectors gcards load the local geometry database.
> 4) If you're testing changes in gemc code, make sure to use the `gemc` executable 
>    in the cloned repository, or the one installed in the `GEMC`/bin directory will be used instead.

     
## Procedure:

Clone the clas12Tags repository:

```bash
git clone https://github.com/gemc/clas12Tags
cd clas12Tags
```

At this point you can either:

1. create and install the geometry databases into the `experiments` directory
2. debug / test a detector database inside the `geometry_source`
   directory.


## 1. Create and Install the geometry databases into the `experiments` directory:

The script `create_geometry.sh` will create a single detector or all geometry databases:

```
Usage: create_geometry.sh [coatjava release options] [detector]

Coatjava options (optional – at most one of -d|-l|-t|-g):
  -l               use latest tag (default)
  -t <tag>         use specific tag, like 12.0.4t
  -g <github_url>  use custom github URL
  -h               show this help

If a detector is given (from the list below), only that detector will be built; 
otherwise all will be processed.

  alert band beamline bst cnd ctof dc ddvcs ec fluxDets ft ftof 
  ftofShield htcc ltcc magnets micromegas pcal rich rtpc targets 
  uRwell upstream
```

The script will install (if not present) the desired tagged coatjava in the directory
`geometry_source` and run the geometry service for the requested detector(s).


> [!Warning]
> By default, the latest coatjava tag is used. This is also the suggested option.
> Other tags can be used but they may not be compatible with the latest code.


Examples:

- `./create_geometry.sh cnd`:
   - install if not present the latest coatjava tag, 
   - create the CND geometry ASCII database
   - create or update updates the SQLite database
  
 
- `./create_geometry.sh`: 
   - install if not present the latest coatjava tag
   - create all the CLAS12 detectors
   - create or update updates the SQLite database

  
- `./create_geometry.sh -t 12.0.4t bst`: 
    - install the coatjava tag 12.0.4t
    - create the BST geometry ASCII database
    - create or update updates the SQLite database

  
## 2. Debug / test a detector geometry in the `geometry_source` directory:

The script above run a script to install coatjava and creates the SQLite database.
If you didn't run `create_geometry.sh` you need to do these things manually. For example, 
to install the latest coatjava and create the geometry database for the CND detector:

```bash
cd geometry_source 
./install_coatjava.sh -l
cd cnd
$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite
./cnd.pl config.dat
```

Change directory to detector of interest inside `geometry_source` and run
the geometry script to create the ASCII and SQLite databases: For example, for ftof:

```bash
cd geometry_source/ftof
./ftof.pl config.dat
```

You will see in the local directory the ASCII databases (geometry and materials txt files),
and the SQLite database `clas12.sqlite` will be updated with the new detector.


> [!NOTE]
> Each detector subdir has two sets of gcards:
> - `<detector>_text_<variation>.gcard`: for debugging the detector geometry 
>   for a specific variation. These uses the ASCII database.
> - `<dectector>_sqlite.gcard`: for running the detector geometry for a 
>   specific run number. This uses the SQLite database `clas12.sqlite` 
>   in the `geometry_source` directory.

These gcards contain their detector's geometry but not 
other CLAS12 components and will only load the detector geometry database in 
the local directory.


## How to compile the source code at JLab

Load the environment as described above [^1][^2], then:

```bash
cd source
scons -jN OPT=1
```

where N is the number of cores available. At JLab, N=40 is a good choice.

[^1]: you will need to load the 
**ccdb** and **hipo** modules, included when with the **clas12** module.
[^2]: for a standalone installation, follow the [ceInstall instructions](https://github.com/JeffersonLab/ceInstall).

# Release workflow

Merging changes in the repository will trigger CI validation workflows and the 
**creation of artifacts** containing the new executable and the 
geometry databases.

These are installed at JLAB in /scigroup/cvmfs using a **cronjob that runs every couple of hours**.

As a result these JLAB installations are up-to-date with this timelines:

- `/scigroup/cvmfs` (used on ifarms) : 2-8 hours after the commit, passing through the CI validation and
  merge queue when necessary.
- `/cvmfs/oasis.opensciencegrid.org` (used on OSG): an additional 4-8 hours after the JLAB
  installation once the CVMFS sync runs.

The GitHub `dev` release is also created nightly by the CI.

### Pull requests

The pull requests will be reviewed and queue for auto-merging into the 
main branch pending passing the CI:

- compilation for fedora36, almalinux94 and ubuntu24
- coatjava validation with 500 events
- run gemc on 1000 events using all gcards in clas12-config/gemc/dev development branch

### Run at JLab:

The available modules can be listed using `module avail gemc`.

Use `module switch` to change to the desired version.

To run GEMC you can select one of the gcards in the clas12-config 
installed on cvmfs. For example:

```
gemc /scigroup/cvmfs/hallb/clas12/sw/noarch/clas12-config/dev/gemc/dev/rga_fall2018.gcard  -N=nevents -USE_GUI=0 
```

> [!NOTE]
> Make sure that the clas12-config version is production for a tagged release, 
> or dev for the latest development version. 
> For **gemc/dev**, you will also need to use the subdir `clas12-config/dev/gemc/dev` 
> You can used `gemc -v` to check the version of gemc.


## Docker images

Docker images for Almalinux, Fedora and Ubuntu based OS systems
are available on [DockerHub](https://hub.docker.com/repository/docker/jeffersonlab/gemc/general).

- dev-ubuntu24
- dev-fedora36
- dev-almalinux94

To run the docker image (for example dev-fedora):

```
docker run -it --rm jeffersonlab/gemc:dev-fedora36 bash
```

On MacOS the additional option `--platform linux/amd64` is needed:

```
docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 bash
```

# Portal to off-site farms CLAS12 Simulations

CLAS12 GEMC simulations can be run on the Open Science Grid (OSG) using the
<a href="https://gemc.jlab.org/web_interface/index.php"> CLAS12 Simulation Submission Portal</a>.


# Profiling

## Time per track

The profile table below is obtained by a GitHub action that runs gemc nightly with the
RGA Spring 2018 configuration with a mix of 1, 2, 3, 5, 10, 15, 20 tracks,
and by using clasdis.

The events come from a picking single tracks from a the following clas12 mcgen generators: clasdis, dvcsgen, las12-elspectro, gibuu, genKandOnePione, onepigen, twopeg.

The clasdis files are:

- clasdis_all : generated with no options
- clasdis_acc: generated with --t 15 35 option (electron theta between 15 and 35)


![Track Profiling](ci/tracks_profile.png?raw=true "Time per track for various configurations")



# Utilities

### Changing a material

The option `SWITCH_MATERIALTO` can be used to change a material of a volume
For example, to change the `G4_lH2` to vacuum:

```
<option name="SWITCH_MATERIALTO" value="G4_lH2, G4_Galactic"/>
```

The option `CHANGEVOLUMEMATERIALTO` can be used to change the material of a volume.
For example, to change the target cell `lh2` material from LH2 to a vacuum:

```
<option name="CHANGEVOLUMEMATERIALTO" value="lh2, G4_Galactic"/>
```



### Removing a detector or a volume

You can remove/comment out the ```<detector>``` tag in the gcard to remove a whole system.
To remove individual elements, use the existance tag in the gcard. For example, to remove the forward micromegas:

```
<detector name="FMT">
    <existence exist="no" />
</detector>
```


## Citations

- [Nucl. Instrum. Meth. A, Volume 959, 163422 (2020)](https://inspirehep.net/literature/1780020)
- [EPJ Web of Conf. Volume 295, 05505 (2024)](https://www.epj-conferences.org/articles/epjconf/abs/2024/05/epjconf_chep2024_05005/epjconf_chep2024_05005.html)



## Maurizio Ungaro

<a href="https://scholar.google.com/citations?user=zkWYILYAAAAJ&amp;hl=en" target="_blank"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/gscholar.png"> </a>
<a href="https://github.com/maureeungaro" target="_blank"><a href="mailto:ungaro@jlab.org"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/github.png"> </a>
<a href="https://inspirehep.net/authors/1322331" target="_blank"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/inspire.png"> </a>
<a href="mailto:ungaro@jlab.org"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/email.png"> </a>





