# The clas12Tags repository


## QuickStart

Create the CLAS12 geometry database for the a detector (here we use CND)

```bash
git clone https://github.com/gemc/clas12Tags
cd clas12Tags
./create_geometry.sh cnd     # build & install the CND detector databases
```

Setup the environment at Jefferson Lab, load a tagged version of gemc:

```bash
module use /scigroup/cvmfs/geant4/modules
module load gemc/5.14
```

Alternatively, use the [clas12 environment](https://clasweb.jlab.org/wiki/index.php/CLAS12_Software_Environment_@_JLab)
for the full CLAS12 software stack, which includes the latest tagged gemc version.

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
- [How to build and install with Meson](#how-to-build-and-install-with-meson)
- [Release workflow](#release-workflow)
	- [Pull requests](#pull-requests)
	- [Run at JLab:](#run-at-jlab)
- [Container images](#container-images)
- [Portal to Off-site farms CLAS12 Simulations](#portal-to-off-site-farms-clas12-simulations)
- [Profiling](#profiling)
	- [Time per track](#time-per-track)
- [Utilities](#utilities)
	- [Changing a material](#changing-a-material)
	- [Removing a detector or a volume](#removing-a-detector-or-a-volume)
- [Citations](#citations)
- [Maurizio Ungaro](#maurizio-ungaro)

<br/>

## Introduction

The clas12Tags repository collects the databases and source code for the Geant4 simulation of the CLAS12 experiments
at Jefferson Lab, providing:

- Tagged version of the geometry database, in the form of ASCII and SQLite files.
- The CLAS12 geometry source code used to create the geometry databases.
- Detectors steering cards (GCARDS) for debugging and testing.
- The GEMC C++ source code and perl API.

The `experiments` directory contains the **development version of the geometry database
of the CLAS12 detectors**, built using the **latest tagged version of coatjava**.



<p align="center">
  <img src="clas12.png?raw=true" alt="CLAS12 detector rendering" width="600">
  <br>
  <em>Figure&nbsp;1: The CLAS12 detector simulation. The electron beam travels left&nbsp;→&nbsp;right.</em>
</p>

## General Information:

- [GEMC Documentation Page](https://gemc.jlab.org/gemc/html/index.html)
- [CLAS12 Discourse Forum: Simulation](https://clas12.discourse.group/c/simulation/9)
- [Clas12-config repository with the various experiments steering cards](https://github.com/JeffersonLab/clas12-config)
- [CLAS12 Software Center Wiki](https://clasweb.jlab.org/wiki/index.php/CLAS12_Software_Center#tab=Communications)
- [CCDB Viewer](https://clasweb.jlab.org/cgi-bin/ccdb/objects)

<br/>

# How to create the CLAS12 geometry databases

## Pre-requisites

You will need:

- `maven`, `java (openjdk >= 17)` and `groovy` to install and run the coatjava geometry service.
- gemc `dev` environment.

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
> Notice:
> 1) If you are testing perl API changes, point **GEMC** to your cloned clas12Tags directory.
> 2) If you are testing geometry changes, point **GEMC_DATA_DIR** the cloned clas12Tags directory.
> 3) If you are testing changes within the geometry_source directory, you do not need to set any
>    additional variables, as the detectors gcards load the local geometry database.
> 4) If you're testing changes in gemc code, make sure to use the `gemc` executable
>     in your cloned repository (source/gemc), or the one from the environment will be used instead.

## Procedure:

Clone the clas12Tags repository:

```bash
git clone https://github.com/gemc/clas12Tags
cd clas12Tags
```

At this point you can:

1. create and install the geometry databases into the `experiments` directory
2. debug / test a detector database inside the `geometry_source`
   directory.

<br/>

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

<br/>

> [!Warning]
> By default, the latest coatjava tag is used. This is also the suggested option.
> Other tags can be used but they are not guaranteed to work.

<br/>

Examples:

- `./create_geometry.sh cnd`:
	- install if not present the latest coatjava tag,
	- create, and install in the `experiments` dir, the CND geometry ASCII database
	- create or update the SQLite database


- `./create_geometry.sh`:
	- install if not present the latest coatjava tag
	- create, and install in the `experiments` dir, all the CLAS12 detectors geometry ASCII database
	- create or update the SQLite database


- `./create_geometry.sh -t 12.0.4t bst`:
	- install the coatjava tag 12.0.4t
	- create, and install in the `experiments` dir, the BST geometry ASCII database
	- create or update the SQLite database

<br/>

## 2. Debug / test a detector geometry in the `geometry_source` directory:

If you didn't run `create_geometry.sh`, install coatjava first, and create the sqlite geometry database:

```bash
cd geometry_source 
./install_coatjava.sh -l
$GEMC/api/perl/sqlite.py -n ../clas12.sqlite
```

Change directory to detector of interest inside `geometry_source` and run
the geometry script to create the ASCII and SQLite databases: For example, for ftof:

```bash
cd geometry_source/ftof
./ftof.pl config.dat
```

You will see in the local directory the ASCII databases (geometry and materials txt files),
and the SQLite database `clas12.sqlite` will be updated with the new detector.

<br/>

> [!NOTE]
> Each detector subdir has two sets of gcards:
> - `<detector>_text_<variation>.gcard`: for debugging the detector geometry
>   or a specific variation using the ASCII database.
> - `<dectector>_sqlite.gcard`: for running the detector geometry for a
>   specific run number using the SQLite database `clas12.sqlite`
>   in the `geometry_source` directory.
> - These gcards contain their detector's geometry but not
>   other CLAS12 components and will only load the detector geometry database in
>   the local directory.


<br/>

# How to build and install with Meson

### Prerequisites

- [clhep](https://gitlab.cern.ch/CLHEP/CLHEP), [xercesc](https://github.com/apache/xerces-c.git),
  [geant4](https://github.com/Geant4/geant4.git). For their installation see also [^1].
- [hipo](https://code.jlab.org/hallb/clas12/hipo-cpp)
- [ccdb](https://code.jlab.org/hallb/clas12/ccdb)

> [!NOTE]
> These prerequisites are satisfied at JLab with `module load geant4 ccdb hipo`.

Configure, compile, install, and run the gcard tests from the `source` directory:

```bash
cd source
meson setup build --prefix=/path/to/install
meson compile -C build
meson install -C build
meson test -C build --print-errorlogs
```

The `api` and `experiments` directories are installed into `<prefix>/` alongside the `gemc` binary.
`GEMC_DATA_DIR` must be set in the calling environment (e.g. via `module load gemc/dev`) so that
gemc can find field maps and cross-detector geometry files at test time.

To run only a specific detector's tests:

```bash
meson test -C build --suite ec --print-errorlogs
```

[^1]: the [g4install](https://github.com/gemc/g4install) provides modules environment and installation
scripts for Geant4.


<br/>

# Release workflow

Merging changes in the repository will trigger various CI validation workflows and the
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

To run GEMC you can select one of the gcards in the clas12-config
installed on cvmfs. For example:

```bash
gemc /scigroup/cvmfs/hallb/clas12/sw/noarch/clas12-config/dev/gemc/dev/rga_fall2018.gcard  -N=nevents -USE_GUI=0 
```

<br/>

> [!NOTE]
> - Make sure that the clas12-config version is production for a tagged release,
	> or dev for the latest development version.
> - For **gemc/dev**, you will need to use the subdir `clas12-config/dev/gemc/dev`


<br/>

## Container images

Images are published to the **GitHub Container Registry** after every successful push to `main`:

```text
ghcr.io/gemc/clas12tags:<gemc-tag>-<os>-<os-version>[-<arch>]
```

Available tags (current Geant4 version `11.4.1`, gemc tag `dev`):

| Image | Tag example |
| --- | --- |
| Ubuntu 24.04 | `ghcr.io/gemc/clas12tags:dev-ubuntu-24.04` |
| Ubuntu 26.04 | `ghcr.io/gemc/clas12tags:dev-ubuntu-26.04` |
| Fedora 44 | `ghcr.io/gemc/clas12tags:dev-fedora-44` |
| AlmaLinux 9.4 | `ghcr.io/gemc/clas12tags:dev-almalinux-9.4` |
| AlmaLinux 10 | `ghcr.io/gemc/clas12tags:dev-almalinux-10` |
| Debian 13 | `ghcr.io/gemc/clas12tags:dev-debian-13` |
| Arch Linux | `ghcr.io/gemc/clas12tags:dev-archlinux-latest` |

Multi-arch manifests (`amd64` + `arm64`) are assembled automatically; append `-amd64` or `-arm64`
to pull a specific architecture.

To start an interactive shell:

```shell
docker run -it --rm ghcr.io/gemc/clas12tags:dev-almalinux-9.4 bash
```

On Apple Silicon add `--platform linux/amd64` if you need the x86-64 variant:

```shell
docker run -it --rm --platform linux/amd64 ghcr.io/gemc/clas12tags:dev-almalinux-9.4 bash
```

Mount a local directory for input/output with `-v`:

```shell
docker run -it --rm -v ~/mywork:/root/mywork ghcr.io/gemc/clas12tags:dev-almalinux-9.4 bash
```

The base Geant4 images used to build these containers come from:

```text
ghcr.io/gemc/g4install:<geant4-tag>-<os>-<os-version>
```

<br/>

# Portal to off-site farms CLAS12 Simulations

CLAS12 GEMC simulations can be run on the Open Science Grid (OSG) using the
<a href="https://gemc.jlab.org/web_interface/index.php"> CLAS12 Simulation Submission Portal</a>.


<br/>

# Profiling

## Time per track

The profile table below is obtained by a [metrics action](https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml)
that runs gemc nightly with the RGA Spring 2018 configuration, with a mix of 1, 2, 3, 5, 10, 15, 20 tracks,
and by using clasdis.

The events come from a picking single tracks from a the following clas12 mcgen generators: clasdis, dvcsgen, las12-elspectro, gibuu, genKandOnePione, onepigen, twopeg.

The clasdis files are:

- clasdis_all : generated with no options
- clasdis_acc: generated with --t 15 35 option (electron theta between 15 and 35)

![Track Profiling](ci/tracks_profile.png?raw=true "Time per track for various configurations")



<br/>

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

<br/>

## Citations

Please make sure to cite the following paper if you use GEMC:

- [Nucl. Instrum. Meth. A, Volume 959, 163422 (2020)](https://inspirehep.net/literature/1780020)
- [EPJ Web of Conf. Volume 295, 05505 (2024)](https://www.epj-conferences.org/articles/epjconf/abs/2024/05/epjconf_chep2024_05005/epjconf_chep2024_05005.html)

<br/>

## Author

Maurizio Ungaro

<a href="https://scholar.google.com/citations?user=zkWYILYAAAAJ&amp;hl=en" target="_blank"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/gscholar.png"> </a>
<a href="https://github.com/maureeungaro" target="_blank"><a href="mailto:ungaro@jlab.org"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/github.png"> </a>
<a href="https://inspirehep.net/authors/1322331" target="_blank"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/inspire.png"> </a>
<a href="mailto:ungaro@jlab.org"><img class="zoomIcon" src="https://maureeungaro.github.io/home/assets/images/home/email.png"> </a>


<br/>
<br/>

<hr>

<br/>
<br/>

# CI

[![Test][badge-test]][workflow-test]
[![Deploy][badge-deploy]][workflow-deploy]
[![CodeQL Advanced][badge-codeql]][workflow-codeql]
[![Clas12-Config GCards Tests][badge-gcards]][workflow-gcards]
[![Local GCards Tests][badge-local-gcards]][workflow-local-gcards]
[![Tracks Validation][badge-tracks]][workflow-tracks]
[![Ntracks Metrics][badge-metrics]][workflow-metrics]
[![Nightly Dev Release][badge-dev-release]][workflow-dev-release]
[![Valgrind Profile][badge-valgrind]][workflow-valgrind]
[![ASCII vs SQLite][badge-ascii-sqlite]][workflow-ascii-sqlite]
[![Clas12-Config Dev/Main Comparison][badge-dev-main]][workflow-dev-main]

[badge-test]: https://github.com/gemc/clas12Tags/actions/workflows/test.yml/badge.svg
[badge-deploy]: https://github.com/gemc/clas12Tags/actions/workflows/deploy.yml/badge.svg
[badge-codeql]: https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml/badge.svg
[badge-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_gcards_test.yml/badge.svg
[badge-local-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/local_gcards.yml/badge.svg
[badge-tracks]: https://github.com/gemc/clas12Tags/actions/workflows/tracks_validation.yml/badge.svg
[badge-metrics]: https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml/badge.svg
[badge-dev-release]: https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml/badge.svg
[badge-valgrind]: https://github.com/gemc/clas12Tags/actions/workflows/valgrind_profile.yml/badge.svg
[badge-ascii-sqlite]: https://github.com/gemc/clas12Tags/actions/workflows/ascii_sqlite_comparison.yml/badge.svg
[badge-dev-main]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_dev_main_comparison.yml/badge.svg

[workflow-test]: https://github.com/gemc/clas12Tags/actions/workflows/test.yml
[workflow-deploy]: https://github.com/gemc/clas12Tags/actions/workflows/deploy.yml
[workflow-codeql]: https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml
[workflow-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_gcards_test.yml
[workflow-local-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/local_gcards.yml
[workflow-tracks]: https://github.com/gemc/clas12Tags/actions/workflows/tracks_validation.yml
[workflow-metrics]: https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml
[workflow-dev-release]: https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml
[workflow-valgrind]: https://github.com/gemc/clas12Tags/actions/workflows/valgrind_profile.yml
[workflow-ascii-sqlite]: https://github.com/gemc/clas12Tags/actions/workflows/ascii_sqlite_comparison.yml
[workflow-dev-main]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_dev_main_comparison.yml

### On pull requests

- **Test** — build across Ubuntu, Fedora, AlmaLinux, Debian, Arch Linux (amd64 + arm64)
- **CodeQL Advanced** — static analysis (C/C++, Python, Actions)
- **Clas12-Config GCards Tests** — run gemc on all gcards in the clas12-config dev branch
- **Local GCards Tests** — run `meson test` on all geometry-source gcards in this repository
- **Tracks Validation** — physics validation with particle tracking

### Nightly

- **Deploy** — build and push container images to `ghcr.io/gemc/clas12tags` after tests pass
- **Nightly Dev Release** — package and publish the `dev` release artifact
- **Valgrind Profile** — memory and performance profiling
- **ASCII vs SQLite** — geometry consistency check between text and database representations
- **Clas12-Config Dev/Main Comparison** — detect geometry regressions between branches
- **Ntracks Metrics** — time-per-track benchmarks across generator configurations
