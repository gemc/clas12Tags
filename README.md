# The clas12Tags repository

The `clas12Tags` repository serves as the simulation resource for the CLAS12 experiments
at Jefferson Lab, providing:

- The CLAS12 detectors geometry database (in the form of ASCII files and a SQLITE database).
- Individual system steering cards (GCARDS)
- A customized version of the GEMC source code tailored specifically for the JLab CLAS12 experiments.
- The CLAS12 geometry source code.

![Alt CLAS12](clas12.png?raw=true "The CLAS12 detector simulation. The electron beam is going from left to right.")

###### The CLAS12 detector in the simulation. The electron beam is going from left to right.

<br>

---

<br>

## General Information:

- [GEMC Documentation Page](https://gemc.jlab.org/gemc/html/index.html)
- [CLAS12 Discourse Forum: Simulation](https://clas12.discourse.group/c/simulation/9)
- [clas12-config repository with the steering cards](https://github.com/JeffersonLab/clas12-config)
- [CLAS12 Software Center Wiki](https://clasweb.jlab.org/wiki/index.php/CLAS12_Software_Center#tab=Communications)
- [CCDB Viewer](https://clasweb.jlab.org/cgi-bin/ccdb/objects)

<br>

---

# How to create the CLAS12 detector geometry database

## Pre-requisites

You will need:

- `java (openjdk >= 17)` and `groovy` installed to run the coatjava geometry service.
- gemc environment.

The above requirements are met at JLab by executing

```
module load clas12
module switch gemc/dev
```

On a local installation you can use `module load gemc/dev` instead.

## Procedure:

Clone the clas12Tags repository:

```
git clone https://github.com/gemc/clas12Tags
cd clas12Tags
```

At this point you can either:

1. install the geometry database for a single detector or all of them into the `experiments`
   directory
2. create a detector geometry inside the `geometry_source`
   directory for debugging purposes.

### 1. Install geometry database into the `experiments` directory:

The script `create_geometry.sh` will create an individual detector geometry or all of them:

```
Usage: create_geometry.sh [detector]
Creates the geometry for the given detector
If no detector is given, all detectors will be run

All detectors: 

alert band beamline bst bstShield cnd ctof dc ddvcs ec fluxDets 
ft ftof ftofShield htcc ltcc magnets micromegas pcal rich 
rtpc targets uRwell upstream
```

The script will install (if not present) the latest tagged coatjava in the directory
`geometry_source` and run the geometry service for the requested detector(s).

Examples:

```
./create_geometry.sh cnd : creates the CND geometry ASCII database, updates the SQLITE database
./create_geometry.sh : creates all the CLAS12 detectors, updates the SQLITE database
```

### 2. Create a single detector geometry in the `geometry_source` directory:

The script above run a script to install coatjava and creates the SQLITE database.
If you didn't run `create_geometry.sh` you need to do these things manually:

```
cd geometry_source 
./install_coatjava.sh -l
$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite
```

Change directory to detector of interest inside `geometry_source` and run
the geometry script to create the ASCII and SQLITE databases: For example, for ftof:

```
cd geometry_source/ftof
./ftof.pl config.dat
```

You will see in the local directory the ASCII databases (geometry and materials txt files),
and the SQLITE database `clas12.sqlite` will be updated with the new detector.


---

## How compile the source code

You will need:

- gemc environment, loaded either with `module load clas12` or `module load gemc hipo ccdb`.
- scons

Run scons in the `source` directory:

```
cd source
scons -jN OPT=1
```

where N is the number of cores available.


---

# Release workflow

Changes to the repository will trigger the **CI creation of artifacts** containing
the new executable and the geometry database.

These are installed at JLAB in /scigroup/cvmfs using a **cronjob that runs every couple of hours**.

As a result these JLAB installations are up-to-date:

- `/scigroup/cvmfs` : 2-8 hours after the commit, passing through the CI validation and
  merge queue when necessary.
- `/cvmfs/oasis.opensciencegrid.org` : an additional 4-8 hours after the JLAB
  installation once the CVMFS sync runs.

The GitHub `dev` release is also created nightly by the CI.

### Pull requests

Please make a pull requests with changes pertaining to the directories:

- **geometry_source**: for changes to the geometry source code.
- **source**: for changes to the GEMC source code.

The changes will be reviewed and queue for auto-merging into the main branch pending passing the CI:

- compilation for fedora36, almalinux94 and ubuntu24
- coatjava validation
- run clas12-config gcards successfully

### Use at JLab:

The following releases of Clas12Tags are installed on CVMFS:

- [dev](release_notes/dev.md) (tagged nightly)
- [5.11](release_notes/5.11.md)
- [5.10](release_notes/5.10.md)
- [4.4.2](release_notes/4.4.2.md)

To load the GEMC environment at JLab:

```commandline
module use /scigroup/cvmfs/hallb/clas12/sw/modulefiles
module load clas12
```

To switch to a different version of gemc use `module switch`. For example:

```
module switch gemc/dev
```

To run GEMC you can select one of the gcards in the clas12-config installed on cvmfs. For example:

```
gemc /scigroup/cvmfs/hallb/clas12/sw/noarch/clas12-config/dev/gemc/dev/rga_fall2018.gcard  -N=nevents -USE_GUI=0 
```

Alternatively the gcards can be downloaded from https://github.com/JeffersonLab/clas12-config



---

## Docker Images

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

<br>

---
<br>

# Portal to Off-site farms CLAS12 Simulations

GEMC simulations can be run on the Open Science Grid (OSG) using the
<a href="https://gemc.jlab.org/web_interface/index.php"> CLAS12 Simulation Submission Portal</a>.

<br>

---


<br>

# Profiling

## Timer per track

A metric is compiled by a GitHub action that runs gemc nightly with the
RGA Spring 2018 configuration with a mix of 1, 2, 3, 5, 10, 15, 20 tracks,
and by using clasdis.

The tracks files come from a mix of:

clasdis, dvcsgen, las12-elspectro, gibuu, genKandOnePione, onepigen, twopeg.

The clasdis files are:

clasdis_all : generated with no options
clasdis_acc: generated with --t 15 35 option (electron theta between 15 and 35)

The results are summarized below.

![Alt Profile](tracks_profile.png ?raw=true "Time per track for various configurations")




<br>

---


<br>

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

<br>

### Removing a detector or a volume

<br>

You can remove/comment out the ```<detector>``` tag in the gcard to remove a whole system.
To remove individual elements, use the existance tag in the gcard. For example, to remove the forward micromegas:

```
<detector name="FMT">
    <existence exist="no" />
</detector>
```

<br>


---

## GitHub Actions

[![Almalinux Build](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_almalinux.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_almalinux.yml)
[![Fedora Build](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_fedora.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/build_gemc_fedora.yml)
[![Nightly Dev Release](https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml)
[![Ntracks Metrics](https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml)
[![Ascii vs Sqlite](https://github.com/gemc/clas12Tags/actions/workflows/txt_sql_comparison.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/txt_sql_comparison.yml)
[![Coatjava Validation](https://github.com/gemc/clas12Tags/actions/workflows/validation.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/validation.yml)
[![GCards Tests](https://github.com/gemc/clas12Tags/actions/workflows/experiment_test.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/experiment_test.yml)
[![CodeQL Advanced](https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml/badge.svg)](https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml)

<br>

---

## Citations

- [Nucl. Instrum. Meth. A, Volume 959, 163422 (2020)](https://inspirehep.net/literature/1780020)
- [EPJ Web of Conf. Volume 295, 05505 (2024)](https://www.epj-conferences.org/articles/epjconf/abs/2024/05/epjconf_chep2024_05005/epjconf_chep2024_05005.html)

<br>

---

## Author

<br>

<a href="https://scholar.google.com/citations?user=zkWYILYAAAAJ&amp;hl=en" target="_blank"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/gscholar.png"> </a>
<a href="https://github.com/maureeungaro" target="_blank"><a href="mailto:ungaro@jlab.org"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/github.png"> </a>
<a href="https://inspirehep.net/authors/1322331" target="_blank"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/inspire.png"> </a>
<a href="mailto:ungaro@jlab.org"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/email.png"> </a>

<br>


---
