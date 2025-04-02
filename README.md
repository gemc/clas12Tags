# The clas12Tags repository

The `clas12Tags` repository serves as the simulation resource for the CLAS12 experiments 
at Jefferson Lab, providing:  
- The CLAS12 detectors geometry database (in the form of ASCII files and a SQLITE database).  
- Individual system steering cards (GCARDS)
- A customized version of the GEMC source code tailored specifically for the JLab CLAS12 experiments.
- The CLAS12 geometry source code.


![Alt CLAS12](clas12.png?raw=true "The CLAS12 detector simulation. The electron beam is going from left to right.")

###### The CLAS12 detector in the simulation. The electron beam is going from left to right.

---

## Pre-requisites

You will need:

- `java (openjdk >= 17)` and `groovy` installed to run the coatjava geometry service.
- gemc environment.

The above requirements are met  at JLab by executing 
```
module load clas12
module switch gemc/dev
```

On a local installation you can use `module load gemc/dev` instead.

## How to create the CLAS12 detector geometry database


Clone the clas12Tags repository:

```
git clone https://github.com/gemc/clas12Tags
cd clas12Tags
```

At this point you can either install the 
geometry database for a single detector or all of them into the `experiments` 
directory, or create a single detector geometry inside the `geometry_source` 
directory for debugging purposes.

### Install geometry database into the `experiments` directory:

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

### Create a single detector geometry in the `geometry_source` directory:

The script above installs coatjava. If you didn't run it, 
you need to install coatjava manually:


```
cd geometry_source 
./install_coatjava.sh -l
```

Change directory to detector of interest inside `geometry_source`. For example ftof:

```
cd geometry_source/ftof
```

If not already present, create the SQLITE database:

```
$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite
```

Run the geometry script to create the ASCII and SQLITE databases:

```
./ftof.pl config.dat
```

You will see in the local directory the ASCII databases (geometry and materials txt files), 
and the SQLITE database `clas12.sqlite` will be updated with the new detector.


---

## How compile the source code

You will need:

- gemc environment, loaded either with `module load clas12` or `module load gemc`.
- scons

Run scons in the `source` directory:

```
cd source
scons -jN OPT=1
```

where N is the number of cores available.


---


## Release workflow

Please make a pull requests with changes pertaining to the directories:

- **geometry_source**: for changes to the geometry source code.
- **source**: for changes to the GEMC source code.

The changes will be reviewed and merged into the main branch. 
A nightly build and a cronjob ensure the latest version of the code and geometry is available on cvmfs.

## Use at JLab:

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

---


## Portal to Off-site farms CLAS12 Simulations

GEMC simulations can be run on the Open Science Grid (OSG) using the
<a href="https://gemc.jlab.org/web_interface/index.php"> CLAS12 Simulation Submission Portal</a>.


---


## FTOn, FTOff configurations


The default configuration for the first experiment is with "FTOn" (Figure 1, Left): complete forward tagger is fully
operational.
The other available configuration is "FTOff" (Figure 1, Right): the Forward Tagger tracker is replaced with shielding,
and the tungsten cone is moved upstream.



|                                                                              |                                                                                                         |
|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/gemc/clas12Tags/main/ftOn.png"/> | <img src="https://raw.githubusercontent.com/gemc/clas12Tags/main/ftOn.png"/>                            |
| FT On configuration: Full, OperationalForward Tagger.                        | FT Off configuration: FT Tracker replaced by shielding, Tungsten Cone moved upstream, FT if turned off. |

<br>

To change configuration from FTOn to FTOff, replace the keywords and variations from:

```
	<detector name="experiments/clas12/ft/ft"                      factory="TEXT" variation="FTOn"/>
	<detector name="experiments/clas12/beamline/cad/"              factory="CAD"  variation="FTOn"/>
	<detector name="experiments/clas12/beamline/beamline"          factory="TEXT" variation="FTOn"/>
```

to:

```
	<detector name="experiments/clas12/ft/ft"                      factory="TEXT" variation="FTOff"/>
	<detector name="experiments/clas12/beamline/cad/"              factory="CAD"  variation="FTOff"/>
	<detector name="experiments/clas12/beamline/beamline"          factory="TEXT" variation="FTOff"/>
```



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



## Run numbers vs Run groups

Source: [calcom run groups](https://clasweb.jlab.org/wiki/index.php/CLAS12_Calibration_and_Commissioning)

|                    |               | 
|--------------------|---------------|
| rga_spring2018     | 3029 - 4326   |
| rga_fall2018       | 4763-5666     |
| rga_spring2019     | 6608-6783     |
|                    |               |
| rgb_spring2019     | 6150 – 6603   |
| rgb_fall2019       | 11093 – 11301 |
| rgb_winter20       | 11323 - 11571 |
|                    |               |
| rgc_summer2022     | 16043-16772   |
| rgc_fall2022       | 16843-17408   |
| rgc_winter23       | 17471-17811   |
|                    |               |
| rgd_fall2023       | 18305 - 19131 |
|                    |               |
| rgf_spring2020     | 11620 - 12282 |
| rgf_summer2020     | 12389 - 12951 |
|                    |               |
| rgk_fall2018_FTOn  | 5674 - 5870   |
| rgk_fall2018_FTOff | 5874-6000     |
| rgk_winter23       | 19200 - 19260 |
| rgk_spring24       | 19300 - 19893 |
|                    |               |
| rgm_fall2021       | 15016 - 15884 |
|                    |               |
| rge_spring2024     |               |

## Feedback

Please use CLAS12 discourse for feedback on anything clas12tags related:

https://clas12.discourse.group

<br>

<br>
