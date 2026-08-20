# clas12Tags

[![Test][badge-test]][workflow-test]
[![Deploy][badge-deploy]][workflow-deploy]
[![CodeQL Advanced][badge-codeql]][workflow-codeql]
[![CLAS12-config GCards Tests][badge-gcards]][workflow-gcards]
[![Local GCards Tests][badge-local-gcards]][workflow-local-gcards]
[![Tracks Validation][badge-tracks]][workflow-tracks]
[![Ntracks Metrics][badge-metrics]][workflow-metrics]
[![Valgrind Profile][badge-valgrind]][workflow-valgrind]
[![ASCII vs SQLite][badge-ascii-sqlite]][workflow-ascii-sqlite]
[![CLAS12-config Dev/Main Comparison][bdm]][workflow-dev-main]
[![Nightly Dev Release][badge-dev-release]][workflow-dev-release]

`clas12Tags` is the GEMC2 reference implementation for CLAS12. It contains the source code, detector geometry,
and configuration databases used to simulate CLAS12 experiments at Jefferson Lab.

The repository provides:

- tagged CLAS12 geometry databases in ASCII and SQLite formats
- the geometry source used to generate those databases
- detector steering cards (gcards) for debugging and validation
- the GEMC2 C++ source and Perl API

The `experiments` directory contains the development version of the CLAS12 detector geometry database, generated
with the latest tagged Coatjava release.

<p align="center">
  <img src="clas12.png?raw=true" alt="CLAS12 detector rendering" width="600">
  <br>
  <em>Figure&nbsp;1: The CLAS12 detector simulation. The electron beam travels left&nbsp;→&nbsp;right.</em>
</p>

<br/>

## Highlights

- Run-dependent CLAS12 detector geometry and variations
- ASCII and SQLite geometry databases
- Geometry generation through the Coatjava geometry service
- Local detector gcards for focused development and validation
- Meson-based GEMC2 build and test suite
- CI-tested container images for Linux `amd64` and `arm64`
- Validation against the CLAS12-config production and development gcards

<br/>

## Quickstart at JLab

Add the selected GEMC installation to `PATH`, then run a matching gcard from CLAS12-config:

```shell
export PATH="/absolute/path/to/clas12Tags-install/bin:$PATH"

gemc /scigroup/cvmfs/hallb/clas12/sw/noarch/clas12-config/dev/gemc/dev/rga_fall2018.gcard \
  -N=100 -USE_GUI=0
```

Use a tagged GEMC installation instead of `dev` for production work, and select CLAS12-config gcards matching
that GEMC version.

<br/>

## Installation

### Prerequisites

The C++ build requires:

- Meson 1.10.1 or newer and a C++17 compiler
- Geant4 11.3.2 or newer
- CLHEP 2.4.7.1 or newer
- Xerces-C 3.2.5 or newer
- Qt 6, OpenGL, SQLite, Expat, and zlib

Meson resolves Assimp, CCDB, HIPO, and `clas12-cmag` through the wraps under `source/subprojects`. A first build
therefore needs network access unless those subprojects are already present.

At Jefferson Lab, this is the only environment setup needed to compile GEMC:

```shell
module use /scigroup/cvmfs/geant4/g4install/modules
module load geant4
```

### Build, test, and install

Configure from `source` with an explicit installation prefix. Release mode, static linking, C++17,
and disabled sanitizers are baked into the project defaults (see `default_options` in `source/meson.build`),
so those never need to be passed. Any default can still be overridden on the command line (e.g.
`-Dbuildtype=debug`). Use an absolute path for the prefix — meson does not expand `~`:

```shell
cd source
meson setup build \
  --prefix=$HOME/clas12Tags-install
meson compile -C build
meson install -C build
meson test -C build --suite clas12 --print-errorlogs -j 1
```

Geant4 ships no `pkg-config` file, so `meson setup` generates `geant4.pc` / `geant4_core.pc` into the
build tree (`build/pkgconfig`) and puts that directory on the `pkg-config` search path internally — no
`PKG_CONFIG_PATH` export or `-Dpkg_config_path` flag is needed. The files are also installed to
`<prefix>/lib/pkgconfig`, where downstream GEMC projects resolve `geant4_core` from the installed tree.
CLHEP, Xerces-C, and Qt are still located through the environment set by `module load geant4`.

The explicit prefix prevents a loaded GEMC installation from becoming the destination accidentally. Installation
also places the field maps under the selected prefix, where tests using `source/build/gemc` can find them.

The tests use the default remote CCDB connection. To use a local snapshot, set it before `meson test`:

```shell
export CCDB_CONNECTION="sqlite:////absolute/path/to/ccdb.sqlite"
meson test -C build --suite clas12 --print-errorlogs -j 1
```

The four slashes are intentional for an absolute SQLite path. Compilation and installation do not require a CCDB
connection, but simulation tests do. A first build and any missing field-map downloads require network access.

To run only one detector suite:

```shell
meson test -C build --suite ec --print-errorlogs -j 1
```

### Run an installed GEMC

The installation places the executable in `<prefix>/bin`, the APIs in `<prefix>/api`, geometry and gcards in
`<prefix>/experiments`, and magnetic field maps in `<prefix>/fields`. GEMC derives its data and field locations
from the executable. For the GEMC executable itself, the only GEMC-specific runtime setup is adding it to
`PATH`:

```shell
export PATH="/absolute/path/to/clas12Tags-install/bin:$PATH"
```

`GEMC_DATA_DIR`, the `FIELD_DIR` environment variable, and `GEMC` are not required to run GEMC. Additional setup
is needed only for these cases:

- Geant4 dataset variables must be available if they are not already provided by the system installation.
- `CCDB_CONNECTION` selects a nondefault CCDB server or local SQLite snapshot.
- `-FIELD_DIR=/path/to/fields` selects field maps outside the standard executable-relative installation.
- `PYTHONPATH` (for the Python API) or `PERL5LIB` (for geometry-generation scripts that live outside
  `api/perl`) may be added to use the APIs. The API modules self-locate, and `GEMC` is not used anywhere.

The [g4install repository][g4install] provides the Geant4 installation scripts and module environment used
by GEMC.

<br/>

## Generating CLAS12 geometry

### Requirements and environment

Geometry generation requires Maven, OpenJDK 17 or newer, Groovy, the GEMC Perl API, and a CCDB connection.
The Perl API modules self-locate, so only the geometry scripts that live outside `api/perl` need that
directory on `PERL5LIB`. `create_geometry.sh` sets this up automatically from its own location; to run the
scripts by hand, point `PERL5LIB` at the install (no `GEMC` variable needed):

```shell
export PERL5LIB="/absolute/path/to/clas12Tags-install/api/perl:${PERL5LIB:-}"
```

When developing locally:

- The Perl and Python APIs load their modules from the repository `api/` directory; no `GEMC` is needed.
- Detector gcards under `geometry_source` already load their databases from the local detector directory.
- The local `source/build/gemc` finds the repository `experiments` directory automatically. Pass
  `-FIELD_DIR=/path/to/fields` when its maps are not in the repository.
- Use the local `source/build/gemc` or `<prefix>/bin/gemc` when testing C++ changes; otherwise the
  module-provided executable may be selected first.

### Create geometry databases

`create_geometry.sh` generates one detector or all detectors and installs the results under
`experiments/clas12`:

```text
Usage: create_geometry.sh [coatjava release options] [detector]

Coatjava options (optional; at most one of -l|-t|-g):
  -l                 use the latest tag (default)
  -t <tag>           use a specific tag, such as 12.0.4t
  -g <github_url>    use a custom GitHub repository
  -c <connection>    use a custom CCDB_CONNECTION
  -h                 show help

Detectors:
  alert band beamline bst cnd ctof dc ddvcs ec fluxDets ft ftof
  ftofShield htcc ltcc magnets micromegas pcal rich rtpc targets
  murt upstream
```

The script installs the selected Coatjava release under `geometry_source` when needed, runs the requested
geometry services, writes the ASCII databases to `experiments/clas12/<detector>`, and creates or updates
`clas12.sqlite`.

> [!WARNING]
> The latest Coatjava tag is the supported default. Other tags may not work with the current geometry source.

Examples:

- `./create_geometry.sh cnd` installs the latest Coatjava release if needed and generates the CND ASCII and
  SQLite geometry.
- `./create_geometry.sh` generates every supported CLAS12 detector.
- `./create_geometry.sh -t 12.0.4t bst` generates BST with Coatjava tag `12.0.4t`.
- `./create_geometry.sh -c "sqlite:////absolute/path/to/ccdb.sqlite" cnd` uses a local CCDB snapshot.

### Develop one detector locally

If `create_geometry.sh` has not already installed Coatjava, install it and initialize the SQLite geometry
database:

```shell
cd geometry_source
./install_coatjava.sh -l
../api/perl/sqlite.py -n ../clas12.sqlite
```

Then run the detector geometry script. For example:

```shell
cd ftof
./ftof.pl config.dat
```

The detector directory receives the ASCII geometry and material files, and the repository-level
`clas12.sqlite` is updated with the detector geometry.

Each detector directory contains two kinds of gcard:

- `<detector>_text_<variation>.gcard` loads an ASCII database for a particular variation.
- `<detector>_sqlite.gcard` loads the run-dependent geometry from `clas12.sqlite`.

These focused gcards load only their detector, not the other CLAS12 systems.

<br/>

## Running at Jefferson Lab

Add the `bin` directory of either a tagged production installation or the `dev` installation to `PATH`. No GEMC
module is required. The matching CLAS12-config path must also be used:

- use the production CLAS12-config tree with a tagged GEMC release
- use `clas12-config/dev/gemc/dev` with the GEMC `dev` installation

<br/>

## Documentation

Useful resources:

- [GEMC documentation][gemc-documentation]
- [CLAS12 simulation forum][simulation-forum]
- [CLAS12-config steering cards][clas12-config]
- [CLAS12 Software Center][clas12-software-center]
- [CCDB Viewer][ccdb-viewer]
- [GEMC3 migration and documentation][gemc3-home]
- [CLAS12 systems for GEMC3][clas12-systems]
- [GEMC roadmap][roadmap]

<br/>

## Container images

Images are published to the GitHub Container Registry after every successful push to `main`:

```text
ghcr.io/gemc/clas12tags:<gemc-tag>-<os>-<os-version>[-<arch>]
```

The current development matrix uses Geant4 11.4.2 and the following image tags:

| Image | Tag example |
| --- | --- |
| Ubuntu 24.04 | `ghcr.io/gemc/clas12tags:dev-ubuntu-24.04` |
| Ubuntu 26.04 | `ghcr.io/gemc/clas12tags:dev-ubuntu-26.04` |
| Fedora 44 | `ghcr.io/gemc/clas12tags:dev-fedora-44` |
| AlmaLinux 9.4 | `ghcr.io/gemc/clas12tags:dev-almalinux-9.4` |
| AlmaLinux 10 | `ghcr.io/gemc/clas12tags:dev-almalinux-10` |
| Debian 13 | `ghcr.io/gemc/clas12tags:dev-debian-13` |
| Arch Linux | `ghcr.io/gemc/clas12tags:dev-archlinux-latest` |

Multi-architecture manifests combine `amd64` and `arm64`, except for Arch Linux, which is `amd64` only. Append
`-amd64` or `-arm64` to select an architecture-specific image.

Start an interactive shell:

```shell
docker run -it --rm ghcr.io/gemc/clas12tags:dev-almalinux-9.4 bash
```

On Apple Silicon, request the x86-64 variant when needed:

```shell
docker run -it --rm --platform linux/amd64 ghcr.io/gemc/clas12tags:dev-almalinux-9.4 bash
```

Mount a local input/output directory:

```shell
docker run -it --rm -v ~/mywork:/root/mywork ghcr.io/gemc/clas12tags:dev-almalinux-9.4 bash
```

The containers are built from:

```text
ghcr.io/gemc/g4install:<geant4-tag>-<os>-<os-version>
```

### Pull request preview images

The [`pr-docker-image`](.github/workflows/pr-docker-image.yml) workflow publishes an `amd64` AlmaLinux 10
image for each pull request and refreshes it after every push:

```text
ghcr.io/gemc/clas12tags:dev-almalinux-10-pr-<number>
```

For example:

```shell
docker run -it --rm ghcr.io/gemc/clas12tags:dev-almalinux-10-pr-123 bash
```

The preview gives authors, reviewers, and CI the same isolated build without requiring a local Geant4 toolchain.
The workflow removes the image when the pull request is closed or merged.

<br/>

## Off-site simulations

CLAS12 GEMC simulations can run on the Open Science Grid through the
[CLAS12 Simulation Submission Portal][simulation-portal].

<br/>

## Release and CI workflow

Merges to `main` run the validation workflows and produce artifacts containing the executable and geometry
databases. A periodic job installs successful builds at Jefferson Lab:

- `/scigroup/cvmfs` on the ifarm is normally updated 2–8 hours after a merge passes CI and the merge queue.
- `/cvmfs/oasis.opensciencegrid.org` is normally updated another 4–8 hours after the Jefferson Lab
  installation, when CVMFS synchronization runs.

CI also refreshes the GitHub `dev` prerelease nightly.

Pull requests are reviewed and enter the merge queue after the required checks pass. The current build matrix
covers Ubuntu, Fedora, AlmaLinux, Debian, and Arch Linux on supported `amd64` and `arm64` runners. Validation
also includes Coatjava geometry generation, local gcards, CLAS12-config gcards, track comparisons, and geometry
consistency checks.

### Pull request checks

- **Test** builds the supported Linux matrix.
- **CodeQL Advanced** performs static analysis of C/C++, Python, and GitHub Actions.
- **CLAS12-config GCards Tests** runs the CLAS12-config development gcards.
- **Local GCards Tests** runs the repository's geometry-source gcards.
- **Tracks Validation** performs particle-tracking validation.

### Scheduled checks

- **Deploy** publishes container images after successful tests.
- **Nightly Dev Release** packages and publishes the `dev` release artifact.
- **Valgrind Profile** performs memory and performance profiling.
- **ASCII vs SQLite** checks geometry consistency between database representations.
- **CLAS12-config Dev/Main Comparison** detects geometry regressions between branches.
- **Ntracks Metrics** benchmarks time per track across generator configurations.

<br/>

## Profiling

The [nightly metrics workflow][workflow-metrics] runs the RGA Spring 2018 configuration with 1, 2, 3, 5, 10, 15,
and 20 tracks per event. Events are sampled from the CLAS12 Monte Carlo generators `clasdis`, `dvcsgen`,
`clas12-elspectro`, `gibuu`, `genKandOnePione`, `onepigen`, and `twopeg`.

The two CLASDIS samples are:

- `clasdis_all`, generated without additional options
- `clasdis_acc`, generated with `--t 15 35` to restrict the electron polar angle to 15–35 degrees

![Time per track for various configurations](ci/tracks_profile.png?raw=true)

<br/>

## Utilities

### Change a material

`SWITCH_MATERIALTO` replaces a material everywhere. For example, replace liquid hydrogen with vacuum:

```xml
<option name="SWITCH_MATERIALTO" value="G4_lH2, G4_Galactic"/>
```

`CHANGEVOLUMEMATERIALTO` changes one named volume. For example, change the `lh2` target cell to vacuum:

```xml
<option name="CHANGEVOLUMEMATERIALTO" value="lh2, G4_Galactic"/>
```

### Remove a detector or volume

Remove or comment out a `<detector>` element to remove an entire system. To disable one volume and its
daughters, set its existence flag. For example, disable the forward micromegas:

```xml
<detector name="FMT">
    <existence exist="no" />
</detector>
```

<br/>

## Citation

If you use GEMC in scientific work, cite:

- [*Nuclear Instruments and Methods in Physics Research Section A* 959, 163422 (2020)][nim-paper]
- [*EPJ Web of Conferences* 295, 05005 (2024)][epj-paper]

<br/>

## Author

Maurizio Ungaro — [Google Scholar][author-scholar], [GitHub][author-github], [INSPIRE][author-inspire],
[ungaro@jlab.org](mailto:ungaro@jlab.org)

[badge-test]: https://github.com/gemc/clas12Tags/actions/workflows/test.yml/badge.svg
[badge-deploy]: https://github.com/gemc/clas12Tags/actions/workflows/deploy.yml/badge.svg
[badge-codeql]: https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml/badge.svg
[badge-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_gcards_test.yml/badge.svg
[badge-local-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/local_gcards.yml/badge.svg
[badge-tracks]: https://github.com/gemc/clas12Tags/actions/workflows/tracks_validation.yml/badge.svg
[badge-metrics]: https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml/badge.svg
[badge-valgrind]: https://github.com/gemc/clas12Tags/actions/workflows/valgrind_profile.yml/badge.svg
[badge-ascii-sqlite]: https://github.com/gemc/clas12Tags/actions/workflows/ascii_sqlite_comparison.yml/badge.svg
[bdm]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_dev_main_comparison.yml/badge.svg
[badge-dev-release]: https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml/badge.svg

[workflow-test]: https://github.com/gemc/clas12Tags/actions/workflows/test.yml
[workflow-deploy]: https://github.com/gemc/clas12Tags/actions/workflows/deploy.yml
[workflow-codeql]: https://github.com/gemc/clas12Tags/actions/workflows/codeql.yml
[workflow-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_gcards_test.yml
[workflow-local-gcards]: https://github.com/gemc/clas12Tags/actions/workflows/local_gcards.yml
[workflow-tracks]: https://github.com/gemc/clas12Tags/actions/workflows/tracks_validation.yml
[workflow-metrics]: https://github.com/gemc/clas12Tags/actions/workflows/ntracs_metrics.yml
[workflow-valgrind]: https://github.com/gemc/clas12Tags/actions/workflows/valgrind_profile.yml
[workflow-dev-release]: https://github.com/gemc/clas12Tags/actions/workflows/dev_release.yml
[workflow-ascii-sqlite]: https://github.com/gemc/clas12Tags/actions/workflows/ascii_sqlite_comparison.yml
[workflow-dev-main]: https://github.com/gemc/clas12Tags/actions/workflows/clas12_config_dev_main_comparison.yml

[g4install]: https://github.com/gemc/g4install
[gemc-documentation]: https://gemc.jlab.org/gemc/html/index.html
[simulation-forum]: https://clas12.discourse.group/c/simulation/9
[clas12-config]: https://github.com/JeffersonLab/clas12-config
[clas12-software-center]: https://clasweb.jlab.org/wiki/index.php/CLAS12_Software_Center#tab=Communications
[ccdb-viewer]: https://clasweb.jlab.org/cgi-bin/ccdb/objects
[gemc3-home]: https://gemc.github.io/home/
[clas12-systems]: https://github.com/gemc/clas12-systems
[roadmap]: https://github.com/orgs/gemc/projects/1/views/4
[simulation-portal]: https://gemc.jlab.org/web_interface/index.php
[nim-paper]: https://inspirehep.net/literature/1780020
[epj-paper]: https://doi.org/10.1051/epjconf/202429505005
[author-scholar]: https://scholar.google.com/citations?user=zkWYILYAAAAJ&hl=en
[author-github]: https://github.com/maureeungaro
[author-inspire]: https://inspirehep.net/authors/1322331
