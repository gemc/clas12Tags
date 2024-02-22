# The clas12Tags repository

The clas12Tags repository maintains a version of gemc dedicated to the JLab CLAS12 experiments,
with the CLAS12 detector geometry and gcards for the various experiment configurations.

It is tagged more frequently than the main gemc repository - as needed by CLAS12 experiments.

The tags distributed as tarball are the tested. Some versions may be missing because they 
contain bugs or inacuraccies. The release notes for those versions are kept in [here](release_notes/all_releases.md).

![Alt CLAS12](clas12.png?raw=true "The CLAS12 detector in the simulation. The electron beam is going from left to right.")

###### The CLAS12 detector in the simulation. The electron beam is going from left to right.

<br>

## Clas12Tags versions installed at JLab on /site and on CVMFS:

<br>

- [5.3](release_notes/5.3.md)
- [5.2](release_notes/5.2.md)
- [5.1](release_notes/5.1.md)
- [4.4.2](release_notes/4.4.2.md)

<br>

To load gemc, point the environment variable SIM_HOME:

- At JLAB: `/group/clas12/packages/`
- On CVMFS: `/cvmfs/oasis.opensciencegrid.org/jlab/hallb/clas12/soft`

Then:

```
source $SIM_HOME/setup.csh
module load clas12
```

The above will load gemc/4.4.2 by default. To load tag 5.3, in addition to the above, use `module switch`:

```
module switch gemc/5.3
```

To run GEMC you can select one of the gcards in $GEMC/../config. For example:

```
gemc $GEMC/../config/rga-fall2018.gcard -N=nevents -USE_GUI=0 
```

The configurations in the gcards are detailed <a href="https://github.com/gemc/clas12Tags/tree/main/config"> here</a>.

The gcards filenames containting `_binaryField` refers to setups using the `cmag` binary field maps.

### Release notes for tags not installed at JLab or on CVMFS:

- [5.0](release_notes/5.0.md)
- [4.4.1](release_notes/4.4.1.md)
- [4.4.0](release_notes/4.4.0.md)

### Release notes for previous versions, not installed at JLab or on CVMFS:

|              <span>               |                                   |                                   |                                   |
|:---------------------------------:|:---------------------------------:|:---------------------------------:|:---------------------------------:|
|  [4.3.2](release_notes/4.3.2.md)  |  [4.3.1](release_notes/4.3.1.md)  |  [4.3.0](release_notes/4.3.0.md)  | [4a.2.4](release_notes/4a.2.4.md) | 
| [4a.2.3](release_notes/4a.2.3.md) | [4a.2.2](release_notes/4a.2.2.md) | [4a.2.1](release_notes/4a.2.1.md) | [4a.2.0](release_notes/4a.2.0.md) | 
| [4a.1.0](release_notes/4a.1.0.md) | [4a.0.2](release_notes/4a.0.2.md) | [4a.0.1](release_notes/4a.0.1.md) | [4a.0.0](release_notes/4a.0.0.md) |
| [3a.1.0](release_notes/3a.1.0.md) | [3a.1.0](release_notes/3a.1.0.md) | [3a.0.2](release_notes/3a.0.2.md) | [3a.0.1](release_notes/3a.0.1.md) |
| [3a.0.0](release_notes/3a.0.0.md) |                                   |                                   |                                   |

<br>

---

## Upcoming developments:

- Upgrade geant4 to 10.7.p03 :soon:
- RF Frequency > RF Period (+fix), read from DB
- Geometry / Run Number
- gcards reorganized to new repository
- RICH digitization (Connor Pecar)
- 
<br>

---

## Portal to Off-site farms CLAS12 Simulations

GEMC simulations can be run on the Open Science Grid (OSG) using the
<a href="https://gemc.jlab.org/web_interface/index.php"> CLAS12 Simulation Submission Portal</a>.

<br>

---

## Docker

The clas12Tags are installed on CVMFS. Provided you can mount cvmfs,
you can use the jeffersonlab/clas12software:cvmfs docker image to run gemc.

For example:

```
docker run -it --rm -v /cvmfs:/cvmfs  jeffersonlab/clas12software:cvmfs  bash
```

To run it interactively using noVNC:

```
docker run -it --rm -v /cvmfs:/cvmfs -p 8080:8080 jeffersonlab/clas12software:cvmfs  bash
```

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
<option name="SCALE_FIELD" value="TorusSymmetric, -0.8"/>
<option name="SCALE_FIELD" value="clas12-newSolenoid, 0.6"/>
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

## Feedback

Please use CLAS12 discourse for feedback on anything clas12tags related:

https://clas12.discourse.group

<br>

<br>
