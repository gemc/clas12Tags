# The clas12Tags repository

The `clas12Tags` repository serves as the simulation resource for the CLAS12 experiments at Jefferson Lab, providing:  
- The CLAS12 detectors geometry database (in the form of ASCII files).  
- Individual system GCARDS.  
- A customized version of the GEMC source code tailored specifically for the JLab CLAS12 experiments.  

This repository is tagged more frequently than:  
- `gemc/source` (the primary GEMC repository).  
- `gemc/detectors` (which contains the source code for generating the databases).  

The increased tagging frequency reflects the more dynamic nature of CLAS12-specific digitization routines and geometry updates compared to the more stable functionality of the GEMC codebase.  


![Alt CLAS12](clas12.png?raw=true "The CLAS12 detector in the simulation. The electron beam is going from left to right.")

###### The CLAS12 detector in the simulation. The electron beam is going from left to right.

# Creating the CLAS12 detector geometry database




### Pre-requisites  

To set up the environment and run the scripts, ensure the following prerequisites are met:  

1. A working [ceInstall](https://github.com/JeffersonLab/ceInstall) environment.  
2. **Groovy** installed.  
3. A [coatjava](https://github.com/JeffersonLab/coatjava) installation, with the `COATJAVA` environment variable set and `$COATJAVA/bin` included in the system `PATH`.  
4. A copy of the [gemc/api](https://github.com/gemc/api) repository located inside `$GEMC/api`.  
5. A copy of the [gemc/detectors](https://github.com/gemc/detectors) repository.  

**Note:** At Jefferson Lab, prerequisites [1-4] are satisfied when using 
the [CLAS12 environment](https://clasweb.jlab.org/wiki/index.php/CLAS12_Software_Environment_@_JLab), 
loaded with the command:  

```bash
module load clas12
```
The utility script `clas12/install_coatjava.sh` in the `gemc/detectors` repository can be used to install `coatjava`.

---

### Running the Scripts

The CLAS12 geometry database is generated using PERL scripts in the `gemc/detectors` repository. Each system (represented by a subdirectory within the `clas12` directory) contains a main PERL script for execution, typically named after the subdirectory. For example:  
- `beamline/beamline.pl`  
- `ctof/ctof.pl`  

To run a script:  
1. Change to the corresponding subdirectory.  
2. Execute the script using the configuration file `config.dat`:  

```bash
cd beamline
./beamline.pl config.dat
```

This will create the ASCII files for the beamline detector 
for all the variations specified in the main script.
This command generates the ASCII files for the specified detector system, covering all variations defined in the main script.

#### Additional Components

Some systems include additional components in the repository, such as:  
- **Beamline:** The `cadBeamline` directory contains STL files derived from CAD models.  
- **Ctof:** the STL files are not in the repository but are downloaded using the geometry service.

#### Special Cases

Two detectors follow different workflows:  
1. **Alert Detector**: Instructions for execution are detailed in the `alert/README.md` file.  
2. **LTCC Detector**: Before running the main script, the following command must be executed to define the mirror parameters:  
   ```bash
   root -q -b mirrors.C
    ```  


<br>

## Clas12Tags versions installed at JLab on /site and on CVMFS:

<br>

- [dev](release_notes/dev.md), use COATJAVA release 11.0.4)
- [5.10](release_notes/5.10.md)
- [4.4.2](release_notes/4.4.2.md)

<br>

To load the GEMC environment through the clas12 environment at JLab:

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


<br>

---

## Portal to Off-site farms CLAS12 Simulations

GEMC simulations can be run on the Open Science Grid (OSG) using the
<a href="https://gemc.jlab.org/web_interface/index.php"> CLAS12 Simulation Submission Portal</a>.

<br>

---

<br>

## How to get and compile the clas12Tags

Load the environment as [described above](#use-gemc-versions-installed-at-jlab-on-site-and-on-cvmfs-).

Get the desired tag from [here](https://github.com/gemc/clas12Tags/tags)
and unpack it (using 5.X as an example):

```
wget https://github.com/gemc/clas12Tags/archive/refs/tags/5.X.tar.gz
tar -xvf 5.X.tar.gz
```

Then compile gemc:

```
cd clas12_tags-5.X/source
scons -jN OPT=1
```

where N is the number of cores available.

<br>

## How to make changes to the clas12Tags

clas12Tags is a repo with source code and geometry derived from gemc/source.
Modifications should be made to the gemc/source repo by forking it
and making a pull request.

Note: gemc uses static function to load specific clas12 code (ugly, fixed in gemc3).
In particular the BMT and FMT hit processes have these two functions:

```
bmtConstants BMT_HitProcess::bmtc = initializeBMTConstants(-1);
fmtConstants FMT_HitProcess::fmtc = initializeFMTConstants(-1);
```

that should be changed to:

```
bmtConstants BMT_HitProcess::bmtc = initializeBMTConstants(1);
fmtConstants FMT_HitProcess::fmtc = initializeFMTConstants(1);
```

to initialize properly BMT and FMT and avoid seg fault when those
detectors are used. This is done in the clas12Tags repo.

# Changing Configurations

## Magnetic Fields

### ASCII:

You can scale magnetic fields using the SCALE_FIELD option. To do that copy the gcard somewhere first, then modify it.
The gcard can work from any location.
Example on how to run at 80% torus field (inbending) and 60% solenoid field:

```
<option name="SCALE_FIELD" value="binary_torus, -0.8"/>
<option name="SCALE_FIELD" value="binary_solenoid, 0.6"/>
```

<br>

## Hydrogen, Deuterium or empty target

By default, the target cell is filled with liquid hydrogen by specifying the "lh2" target variation.
To use liquid deuterium instead use the variation "lD2" instead.

To use an empty target instead, use the SWITCH_MATERIALTO option.

```
<option name="SWITCH_MATERIALTO" value="G4_lH2, G4_Galactic"/>
```

<br>

## Event Vertex

<br>
While the gcards takes care of the target volumes positions (for example, in rga_spring2019 it is moved upstream by 3cm),
it is up to the generators and the LUND files to place the event in the correct location.

The <a href="https://github.com/gemc/clas12Tags/tree/master/5.1/config"> surveyed target positions</a> are listed
below:<br>

- rga_spring2018</b>: -1.94cm
- rga_fall2018</b>:  -3.0cm
- rgk_fall2018_FTOn</b>:  -3.0cm
- rgk_fall2018_FTOff</b>:  -3.0cm
- rgb_spring2019</b>: -3.0cm
- rga_spring2019</b>: -3.0cm
- rgb_fall2019</b>:   -3.0cm

<br>

## Removing a detector or a volume

<br>

You can remove/comment out the ```<detector>``` tag in the gcard to remove a whole system.
To remove individual elements, use the existance tag in the gcard. For example, to remove the forward micromegas:

```
<detector name="FMT">
    <existence exist="no" />
</detector>
```

<br>

## Detector Sources

<br>

The CLAS12 detector geometry sources are kept in the
<a href="https://github.com/gemc/detectors"> detector git repository</a>.

The CLAS12 geometry services are kept in the
<a href="https://github.com/JeffersonLab/clas12-offline-software/blob/development/common-tools/clas-jcsg/src/main/java/org/jlab/detector/geant4/v2/">
java geant4 factory git repository</a>.

<br>

## FTOn, FTOff configurations

<br>

The default configuration for the first experiment is with "FTOn" (Figure 1, Left): complete forward tagger is fully
operational.
The other available configuration is "FTOff" (Figure 1, Right): the Forward Tagger tracker is replaced with shielding,
and the tungsten cone is moved upstream.

The simulations in preparation of the first experiment should use the default version FTOn.
FTOff will be used only by experts for special studies in preparation for the engineering run.

|                                                                              |                                                                                                         |
|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/gemc/clas12Tags/main/ftOn.png"/> | <img src="https://raw.githubusercontent.com/gemc/clas12Tags/main/ftOn.png"/>                            |
| FT On configuration: Full, OperationalForward Tagger.                        | FT Off configuration: FT Tracker replaced by shielding, Tungsten Cone moved upstream, FT if turned off. |

<br>

To change configuration from FTOn to FTOff, replace the keywords and variations from:

```
<detector name="ft" factory="TEXT" variation="FTOn"/>
<detector name="beamline" factory="TEXT" variation="FTOn"/>
<detector name="cadBeamline/" factory="CAD"/>
```

to:

```
<detector name="ft" factory="TEXT" variation="FTOff"/>
<detector name="beamline" factory="TEXT" variation="FTOff"/>
<detector name="cadBeamlineFTOFF/" factory="CAD"/>
```

### Run numbers vs Run groups

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
