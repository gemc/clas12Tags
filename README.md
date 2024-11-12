# The clas12Tags repository

The clas12Tags repository maintains a version of gemc dedicated to the JLab CLAS12 experiments,
with the CLAS12 detector geometry and gcards for the various experiment configurations.

It is tagged more frequently than the main gemc repository - as needed by CLAS12 experiments.

The tags distributed as tarball and maintained as modules are tested. Some versions may be deleted because they 
contain bugs or inaccuracies. The release notes for those versions are accumulated in the
releases notes for each distributed tag.

![Alt CLAS12](clas12.png?raw=true "The CLAS12 detector in the simulation. The electron beam is going from left to right.")

###### The CLAS12 detector in the simulation. The electron beam is going from left to right.

<br>

## Clas12Tags versions installed at JLab on /site and on CVMFS:

<br>

- [5.10](release_notes/5.10.md)
- [4.4.2](release_notes/4.4.2.md)
- [dev](release_notes/dev.md) : notice this is the development version and may contain bugs.

<br>

To load gemc through the clas12 environment at JLab:

```commandline
module use /scigroup/cvmfs/geant4/modules 
module load geant4
```

To switch to a different version of gemc use `module switch`. For example:

```
module switch gemc/dev
```

To run GEMC you can select one of the gcards in the clas12-config installed on cvmfs. For example:

```
gemc /cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/sw/noarch/clas12-config/dev/gemc/rga-fall2018.gcard -N=nevents -USE_GUI=0 
```

Alternatively the gcards can be downloaded from https://github.com/JeffersonLab/clas12-config



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

## Validation

See [clas12-validation](https://github.com/jeffersonlab/clas12-validation) for validation of the CLAS12 simulation.
In particular check this validation.yml 

## Feedback

Please use CLAS12 discourse for feedback on anything clas12tags related:

https://clas12.discourse.group

<br>

<br>
