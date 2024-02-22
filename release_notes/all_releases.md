# clas12_tags 5.7

- added SQLITE support for geometry and materials
- fixed vertex units

```  
  > gemc version: gemc 5.7

  > FIELD_DIR: /opt/jlab_software/noarch/data/magfield
  > GEMC_DATA_DIR: /opt/jlab_software/1.0/macosx14-clang15/clas12Tags/5.7
  > G4DATA_DIR: /opt/jlab_software/1.0/macosx14-clang15/geant4/10.6.2/data/Geant4-10.6.2/data
  > G4_VERSION: 10.6.2
  > G4INSTALL: /opt/jlab_software/1.0/macosx14-clang15/geant4/10.6.2

```

<br>

### To load production tag 5.7 at JLab, use the following commands:

```
source /group/clas12/packages/setup.[c]sh
module load clas12
module switch gemc/5.7
```

<br>
   

# clas12_tags 5.6

- identical to 5.6 but uses Geant4 10.7.4 instead of 10.6.2

```  
  > gemc version: gemc 5.6

  > Environment:

  > FIELD_DIR: /opt/jlab_software/noarch/data/magfield
  > GEMC_DATA_DIR: /opt/jlab_software/1.1/macosx14-clang15/clas12Tags/5.6
  > G4DATA_DIR: /opt/jlab_software/1.1/macosx14-clang15/geant4/10.7.4/data/Geant4-10.7.4/data
  > G4_VERSION: 10.7.4
  > G4INSTALL: /opt/jlab_software/1.1/macosx14-clang15/geant4/10.7.4

```

<br>

### To load production tag 5.6 at JLab, use the following commands:

```
source /group/clas12/packages/setup.[c]sh
module load clas12
module switch gemc/5.6
```



<br>
   

# clas12_tags 5.5

- added uRwell geometry and digitization 
- FADC time is double not int. Precision is 62.5ps
- target and beamline vacuum windows now native geant4 volumes
- fixed width of scattering chamber vacuum window and added beamline vacuum window
- added instrospection: -v, --v, -version, --version will show the version of gemc and the following:
- field persistence for 2 and 3d maps is float instead of double
- updated RICH hitprocess
- updated interface to FrequencySyncSignal to pass one of engine status longs as seed, to guarantee reproducibility of RFs
- added support for Full_transsolenoid_x161_y161_z321_March2021 binary map.

```  
  > gemc version: gemc 5.5

  > Environment:

  > FIELD_DIR: /opt/jlab_software/noarch/data/magfield
  > GEMC_DATA_DIR: /opt/jlab_software/macosx13-clang15/sim/1.0/clas12Tags/5.4
  > G4DATA_DIR: /opt/jlab_software/macosx13-clang15/sim/1.0/geant4/10.6.2/data/Geant4-10.6.2/data
  > G4_VERSION: 10.6.2
  > G4INSTALL: /opt/jlab_software/macosx13-clang15/sim/1.0/geant4/10.6.2

```

<br>

### To load production tag 5.5 at JLab, use the following commands:

```
source /group/clas12/packages/setup.[c]sh
module load clas12
module switch gemc/5.5
```

<br>
   

# clas12_tags 5.4

- RF Frequency > RF Period 
- read RF parameters from DB if RFSETUP is set to `clas12_ccdb`
- RICH digitization (Connor Pecar, partially completed)
- updated RICH geometry

Standardized fadc time and tdc as follows:

```
	int fadc_time = convert_to_precision(time_in_ns);
	int tdc = time_in_ns/a1;
```

where
```
	double fadc_precision = 0.0625;  // 62 picoseconds resolution
	int convert_to_precision(double tdc) {
		return (int( tdc / fadc_precision ) / fadc_precision);
	}
```

1. time to tdc constants from CCDB 
2. verify time_to_tdc used in LUND background when applicable
2. fadc_time comes from convert_to_precision (time_in_ns) 

| detector | CCDB table                  | 
|----------|-----------------------------|
| band     | /calibration/band/tdc_conv  | 
| cnd      | /calibration/cnd/TDC_conv   | 
| ctof     | /calibration/ctof/tdc_conv  |
| ecal     | /calibration/ec/timing (a1) |
| ft_cal   |                             | 
| ft_hodo  |                             | 
| ftof     | /calibration/ftof/tdc_conv  |
| htcc     | /calibration/htcc/tdc_conv  | 
| ltcc     | /calibration/ltcc/tdc_conv  | 
| rich     |                             | 
| rtpc     |                             | 



- the following options are added/updated in the gcard:

  - SAVE_ALL_MOTHERS=1
  - SKIPREJECTEDHITS=1

 The following additional option to enable truth matching is 
 commented out and added on the OSG portal.
  - INTEGRATEDRAW=“*”


These changes do not affect the single electrons events memory usage (stays about ~1.0g) 
and increase the corresponding running time for 2000 events on ifarm,
from 437 seconds (4.58Hz) to  581 seconds (3.44Hz), or 25%, 
due to looping over all tracks for each event.



<br>

### To load production tag 5.4 at JLab, use the following commands:

```
source /group/clas12/packages/setup.[c]sh
module load clas12
module switch gemc/5.4
```


<br>
   

# clas12_tags 5.3 compatible with COATJAVA 6.5.6.1 and above. Deprecated.

- removed the switch_antialiasing OpenGL function to make it compatible with apple arm chips.
- the binary field entry is now a string containing, in order, the solenoid and torus field maps filenames, separated
by a colon. For example: 
  - `Symm_solenoid_r601_phi1_z1201_13June2018:Full_torus_r251_phi181_z251_25Jan2021`
  - `Symm_solenoid_r601_phi1_z1201_13June2018:Symm_torus_r2501_phi16_z251_24Apr2018`

  The first one of these two examples is the one used in reconstruction, which is now also used in gemc. 
  The second one is the one used in the past in gemc, and equivalent to the ASCII maps.  

- from Raffaella: added option of choosing the beam particle time independently of the LUMI time window, 
  random population of beam bunches with lumi options
- last-a-foam geometry update for EC
- fadc time now includes 16 picoseconds precision


<br>
   

# clas12_tags 5.2 compatible with COATJAVA 6.5.6.1 and above. Deprecated.

4/14/23: This is a patched version that removed the switch_antialiasing OpenGL function to make it compatible with apple arm chips.

- addressing several warnings in the code due to sprintf 
- added option of choosing the beam particle start time (Raffaella) 
- binary magnetic field available configurations: 

  - c12BinaryTorusSymm2018Solenoid2018:`Symm_solenoid_r601_phi1_z1201_13June2018 Symm_torus_r2501_phi16_z251_24Apr2018`
  - c12BinaryTorusFull2020Solenoid2018:`Symm_solenoid_r601_phi1_z1201_13June2018 Full_torus_r251_phi181_z251_03March2020`
  - c12BinaryTorusFull2021Solenoid2018:`Symm_solenoid_r601_phi1_z1201_13June2018 Full_torus_r251_phi181_z251_25Jan2021`

- binary field maps `c12BinaryTorusFull2021Solenoid2018` set to be the default.
- added gcard options for SCALE_FIELD and DISPLACE_FIELDMAP: binary_torus and binary_solenoid to scale the binary field maps.
- fixed active fields not being written in the hipo output for binary maps
- PDG encoding for hipo output redirected to user friendly values: 
  - deuteron: 45
  - triton: 46
  - alpha: 47
  - He3: 49


<br>

   

# clas12_tags 5.1 compatible with COATJAVA 6.5.6.1 and above. Deprecated.


4/14/23: This is a patched version that removed the switch_antialiasing OpenGL function to make it compatible with apple arm chips.

- Binary Field Map Using cMag
- Added config bank GECM::config 
- Added 45 (deuteron, pdg=1000010020), 46 (triton, pdg=1000010030), 47 (alpha, pdg=1000020040), 49 (He3, pdg=1000020030)
- Added raster bank RASTER::adc 
	- given vx, vy of the first particle: 
	- component = 1=vx 2=vy
	- ped = (vx- p0) / p1, where p0, p1 from  /calibration/raster/adc_to_position
- Removed some problematic LTCC volumes from cad imports (side frame and some nose volumes). This will be revised and added later
- Fixed PRINT_EVENT calling g4random
- Using new (geant4-standard) MixMaxRng- this also show more accurate seeds status
- New EVENT_VERBOSITY flag for dedicated event verbosity
- Added nan checks for LUND files numbers
- Added nan checks for values to field getters
- Added microwell digitization
- Added lH2 target variation
- Thresholds for CND using values, sigmas from CCDB /calibration/cnd/Thresholds
- Thresholds for CTOF, FTOF using values from CCDB /calibration/c[f]tof/threshold
- Efficiency for CTOF, FTOF using values from CCDB /calibration/c[f]tof/efficiency
- Added gcards in 5.1/config with added suffix _txtField to use the text fields instead of the binary field maps
- Removed evio support for clas12tags. gemc main still supports evio 
- added flux bank to hipo output

- RASTER_VERTEX:
	- Added raster option RASTER_VERTEX:
	  Randomizes the x, y generated partice vertexes in an ellipse defined by the x, y radii, around their values.
          If the third argument "reset" is given, the vertexes are centered at zero
```
           - example 1: -RASTER_VERTEX="2*cm, 3*cm"

             This randomizes the vertexes around the original LUND values.

           - example 2: -RASTER_VERTEX="2*cm, 3*cm, reset"

             This randomizes the vertexes around zero.
```

- BEAM_SPOT:

	- Randomizes the x, y generated particle vertex shifts in an ellipse defined by the x, y radii and sigmas. An additional parameters defines the ellipse counterclockwise rotation along the z-axis.

By default, the shift is relative to the original LUND vertex values.
If a sixth argument “reset” is given, the vertexes are relative to (VX, VY) = (0, 0)

```
          - example 1 (preserves LUND original vertices): -BEAM_SPOT="2*cm, 3*cm, 0.2*cm, 0.1*cm, 22*deg"
             
             This randomizes the vertexes around the original LUND values, but shifted by (VX, VY) = (2, 3) cm.
             A gaussian with sigmas (SX, SY) = (0.2, 0.1) cm are used, and the ellipse is rotated 22 degrees around z.


           - example 2: -BEAM_SPOT="2*cm, 3*cm, 0.2*cm, 0.1*cm, 22*deg, reset"
             
             Same as above except the randomization is directly applied around (VX, VY) = (2, 3)cm.
```

- RANDOMIZE_LUND_VZ:

	- Added option RANDOMIZE_LUND_VZ:
	  Randomizes the z vertexes using, in order: Z shift, DZ sigma.
	  By default the randomization is relative to the LUND vertex values.
	  If the third argument "reset" is given, the vertexes are relative to VZ=0.

```
           - example 1 (preserves LUND original vertices):  -RANDOMIZE_LUND_VZ="-3*cm, 2.5*cm"
             
             Randomizes the z vertex by plus-minus 2.5cm around the original LUND values, and applies a shift it of -3cm

           - example 2:  -RANDOMIZE_LUND_VZ="-3*cm, 2.5*cm, reset "
             
             Randomizes the z vertex by plus-minus 2.5cm around VZ = -3cm
```

- added DETECTOR_INEFFICIENCY and APPLY_THRESHOLDS options


<br>


<br>
   

# clas12_tags 5.0 compatible with COATJAVA 6.5.6.1 and above. Deprecated.

- Hipo4 output
- Added star "\*" to INTEGRATEDRAW option: -INTEGRATEDRAW="\*" will activate the true info for all sensitive detectors
- pcal and ec hitprocesses merged into one: ecal
- cnd direct and indirect hits are now two separate hit entries and use the standard hipo identifiers sector layer component 
- BAND downstream/ upstream  hits are now two separate hit entries and use the standard hipo identifiers sector layer component



# clas12_tags 4.4.2 compatible with COATJAVA 6.5.6.1 and above


4/13/23: This is a patched version that removed the switch_antialiasing OpenGL function to make it compatible with apple arm chips.

- bug fix in torus field linear interpolation routine
- added passive materials in the central detector region
- added HTCC passive materials: windows and cones for default, fall18 and spring18 variations
- added HTCC variations and corresponding shifts to gcards
- better airgap to fit into htcc and also no interference with target
- added rich sector 4 java variation geometry and entry in gcards (passive materials only)
- bus cable width fix for BST
- fmt routine use local coordinates
- added time signal and changed BMT step size to 100 um
- added geantino digitization for BMT
- FMT mod slim by maxime for rgm
- adding step limiter for chargedgeantino
- added RG-C configuration
- removed target 1mm xy shifts
- removing torlon ring adapted from cad target
- fix 4.4.2 and 5.0 conform to OPTICALPHOTONPID. notice: this does depend on the geant4 version.
- added band geometry and digitization 
- explicit c++11 in SConstruct as it still uses EVIO

<br>

### To load production tag 4.4.2 at JLab, use the following commands:

```
source /group/clas12/packages/setup.[c]sh
module load clas12
module switch gemc/4.4.2
```

<br>
   

# clas12_tags 4.4.1. Deprecated. 

- z tracking limit changed to 9m from 8m in the gcards 





# clas12_tags 4.4.0. Deprecated.

- geant4 10.6 support 
- conform all detectors to read RUNNO and DIGITIZATION_VARIATIONS in the digitization 
- add time offsets for: LTCC 
- add time offsets for: EC, PCAL 
- HTCC mc_gain implementation 
- conform all detectors to read DIGITIZATION_TIMESTAMP in the digitization 
- dc, ec, htcc resolution matching 
- gcards, yaml files from 4.4.0 and on in a dedicated “config” subdir 


# clas12_tags 4.3.2. Deprecated.

- FILTER_HADRONS option to write out events that have hit from specific hadrons in them
- Rich sector 4 passive materials
- FMT use "rgf_spring2020" variation with 3 layers and in retrieving Z0 in the digitization
- RTPC geometry and digitization for the Bonus experiment
- Target geometry for the Bonus experiment
- GUI background color changed to white
- Neutrals particles color changed to blue
- Double radius for hits above thresholds
- allow two sequential rotations in the detector definition
- TOFs resolutions pars from CCDB
- Move LUND vertex based on gcard entry
- Detector time signal shift to match data: FTOF and DC

# clas12_tags 4.3.1. Deprecated.

- FTOF Time resolution updated based on data
- Option  <a href="https://gemc.jlab.org/gemc/html/documentation/rerunEvents.html">SAVE_SELECTED, RERUN_SELECTED</a> to save RNG state for certain particles, detector
- Option  <a href="https://gemc.jlab.org/gemc/html/documentation/ancestry.html"> SAVE_ALL_ANCESTORS </a> to save complete particles hierarchy in output (evio2root also updated)
- gcards for rg-a different run-periods
- gcards for rg-b different run-periods
- ec, pcal digitization removed obsolete constants
- moved ftof shield in the correct position
- Option written in JSON format
- rga_fall2018 variations for: FTOF, EC, PCAL, CTOF geometry services
- default variation for DC geometry service
- ltcc variarions for different run periods
- added Geometry variation as a gcard option: DIGITIZATION_VARIATION, to be used by digitization routines.
- target position added to BMT, CTOF digitization position shift, read from CCDB using DIGITIZATION_VARIATION
- beam background merging is extended to all detectors
- FTOF and CTOF resolutions matched to data
- option RECORD_MIRRORS renamed RECORD_OPTICALPHOTONS

# clas12_tags 4.3.0. Deprecated.

- Updated DC geometry using latest survey (May 18 Entry in DB) 
- Fixed bug that prevented material name from being displayed in the GUI
- 3d cartesian field map support
- new geant4 version: 10.4.p02
- 51 micron tungsten shield (for bst) surrounding the target
- calorimeters: reading ecal effective velocity from CCDB
- change htcc time offset table to use the same used in reconstruction
- Tony Forest: Added polarized target geometry/material and cad volume.






# clas12_tags 4a.2.4. Deprecated.

- Use new torus field map
- FMT shift by 8mm
- use run number 11 as default in the gcard
- FMT background hits
- production cut set for individual volumes in the options
- new geant4 version
- env variable "GEMC_DATA_DIR" as a base path in the gcard (gcard is now portable to other systems)
- bst tungsten and heat shield
- LTCC Nose CAD model
- magnetic field map displacements and rotations with command line options
- FAST MC mode 10, 20 output fixed
- new solenoid field map used by default (scaled by -1)


# clas12_tags 4a.2.3. Deprecated.

- ctof, ftof banks: 1 ADC output / pmt instead of ADCL/ADCR for a single paddle)
- CTOF, FTOF Paddle to PMT digitization for FADC
- background merging algorithm framework
- background merging algorithm implementation in digitization: DC, BST and MM.
- Correct field geant4-caching
- Solenoid integration method: G4ClassicalRK4 to fix some geant4 navigation issues in the field. Slower but more reliable (should have less crashes)
- SYNRAD option to activate synchrotone radiation in vacuum (SYNRAD=1) or any material (SYNRAD=2)
- dc gas material changed to 90% Ar, 10% G4_CARBON_DIOXIDE.
- RF shift from target center: added option RFSTART: Radio-frequency time model. Available values are:
  - "eventVertex, 0, 0, 0" (default): the RF time is the event start time + the light time-distance of the first particle from the point (0,0,0)
  - "eventTime".....................: the RF time is identical to the event start time


# clas12_tags 4a.2.2. Deprecated.

- target from CAD
- htcc wc invisible
- no transparency in MM
- threshold mechanism
- rotate LUND bank to flat
- final beamline configuration
- LTCC sector 4 removed
- LTCC sector 1 removed
- DC: Removed unused lines and calculation of smeared doca
- generator user information are now in two dedicate banks: user header (TAG 11), and user particle infos (TAG 22)
- MM overlaps with target fixed
- New numbering scheme for CTOF, CND

# clas12_tags 4a.2.1. Deprecated.

- fixes to CAD modeling of both the beamline and the torus
- forward carriage volume fixed to accomodate beamline and shielding
- fixed CND / CTOF overlaps
- updated latest micromegas geometry
- MM: Adjust transverse diffusion and ionization potential
- updated latest BST
- 3 + 3 configuration BST + MM
- new vacuum pipe
- new shield downsttream of the torus
- LTCC box hierarchy fixed
- LTCC frame is CAD + copies
- corrected mini-stagger values for DC
- Added TDC calibration constants to ec,pcal hitprocess
- FADC mode 1 (still tuning it to make it exactly like Serguei DAQ)
- reading tdc_conv for ctof from database
- fixed an issue with the header bank where the LUND info index was not correct

# clas12_tags 4a.2.4. Deprecated.

- use JLAB_VERSION 2.1, with new mlibrary
- Micromegas: updated  geometry and digitization
- DC: realistic time to distance function, reading constants from CCDB
- DC: ministagger for DC region 3: "even closer" layers 1,3,5: +300um, SL 2,4,6: -300um
- LTCC: Reading CCDB SPE calibration constants
- LTCC: Smearing ADC based on calibration constants
- CTOF javacad instead of cad (should be indentical)
- Fixed smeared infor in generated summary for FASTMC mode
- improved/fixed CND digitization routine
- updated RF timing (mlibrary)
- BST+MM: using 3+3 configurations (no FMT)

# clas12_tags 4a.1.0. Deprecated.

- fixed a bug that affect output file size
- fixed bug that affected multiple cad imports
- added micromegas geometry and hit processes
- RF output correct frequency in the clas12 gcard
- updated FT geometry and hit process
- updated ftof geometry
- added reading of FTOF reading of tdc conversion constants from the database
- check if strip_id is not empty in bmt_ and fmt_strip.cc, otherwise fill it.

# clas12_tags 4a.0.2. Deprecated.

- full (box, mirrors, pmts shields and WC) LTCC geometry
- LTCC hit process routine.


# clas12_tags 4a.0.1. Deprecated.

- FTOF geometry fix


# clas12_tags 4a.0.0. Deprecated.

- Fixes in source and hit process for FTOF
- added EC gains.
- Java geometry uses now coatjava 3.
- Database fixed for DC geometry.
- Linear time-to-distance for DC.
- CTOF in the KPP position configuration in the new kpp.gcard.

# clas12_tags 3a.1.0. Deprecated.

- DC time-to-distance implementation.


# clas12_tags 3a.0.2. Deprecated.

- CND fix.



# clas12_tags 3a.0.1. Deprecated.

- ctof has status working.



# clas12_tags 3a.0.0. Deprecated.

- FTOF and CTOF paddle delays from CCDB
- CTOF center off-set.


