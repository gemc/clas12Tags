
# CLAS12 TARGETS

The engineering models are kept on 
the [engineering wiki](https://wiki.jlab.org/Hall-B/engineering/hallb_eng_wiki/index.php/Main_Page).


## Windows


## Geometry

To build the geometry, run the following command:

./targets.pl config.dat

---

# Experiments:


## RGF: Sept 22 2022

Author: Yu-Chun Hung

Experiment Description: Measure the structure function F2 of the neutron by 
tagging the spectator proton in the RTPC detector. Deuterium, hydrogen, and helium gas are used at 5.6 atm pressure.


## RGC: Summer 2022

Apollo Polarized Targets

## RGM: Sept 20 2022

Author: Justin Estee

Experiment Description: Short Range Correlations & Electrons for Neutrinos experiment 

RCDB for RGM: 

https://clasweb.jlab.org/rcdb/runs/search?runFrom=15015&runTo=15884&q=event_count%3E100000+and+run_start_time


## Variations: 

### Liquid Targets (Standard 5cm liquid cell)

- lH2: liquid Hydrogen
- lD2: liquid Deuterium
- lHe: liquid Helium

### RGM Solid Targets

Original author: Justin Paulson
Current maintainer: Andrew Denniston awild@mit.edu

- **RGM_2_Sn**: single foil tin target in beamline > **rgm_fall2021_Sn**
- **RGM_2_C**: single foil carbon target in beamline > **rgm_fall2021_C**
- **RGM_8_C_L**: 4-foil carbon target in beamline. Large carbon target option. > **rgm_fall2021_Cx4**
- **RGM_8_Sn_L**: 4-foil tin target in beamline. Large tin target option. > **rgm_fall2021_Snx4**
- **RGM_8_C_S**: 4-foil carbon target in beamline. Small carbon target option. > ???? 
- **RGM_8_Sn_S**: 4-foil tin target in beamline. Small tin target option. > ????
- **RGM_Ca**: Calcium target cell > **rgm_fall2021_Ca** (in DB there's 40Ca and 48Ca)

### Scattering chamber CAD directories

- cad: standard scattering chamber and liquid cell target wall entrance and exit material
- cad_rgm - standard scattering chamber without liquid cell wall and upstream window, only downstream window and pipe included (use with solid targets)
- cad_poltar - deprecated on 5/8/2025.

## How to use it in the gcard
### Liquid Targets
Use "cad" variation with all liquid targets
<detector name="experiments/clas12/targets/cad/"   factory="CAD"/>
<detector name="experiments/clas12/targets/target" factory="TEXT" variation="rga_spring2019"/>

### Solid Targets

Use "cadrgm" variation with all solid targets
<detector name="experiments/clas12/targets/cadrgm/"   factory="CAD"/>
<detector name="experiments/clas12/targets/target" factory="TEXT" variation="rgm_fall2021_C"/>


## RG-D: May 17th, 2024

Author: Lamiaa El Fassi

Experiment Description: Color Transparency & nTMDs

### Variations: 
1. Liquid Targets (Standard 5cm liquid cell):
lD2 - liquid Deuterium

2. Solid Targets:
lD2CxC - Empty lD2 cell + two 12C foils in the beamline
lD2CuSn - Empty lD2 cell + 63Cu and 120Sn in series in the beamline

### How to use it in the gcard
1. For lD2 variations:
Set it up as in "clas12_lD2-RGD.gcard", and
shift the target upstream by 50 mm, see  "clas12_lD2-RGD.gcard".
2. Solid Targets:
Set it up for lD2CxC/lD2CuSn variation as in "clas12_12C-RGD.gcard/clas12_120Sn-RGD.gcard or clas12_63Cu-RGD.gcard", and 
shift the whole target assembly upstream by 150 mm to get the two solid foils @ -7.5 cm and -2.5 cm, as the entrance and exit windows for the lD2 case; see the mentioned three solid-foil gcards.
<detector name="target">    <position x="0.0*cm"  y="0.0*cm"  z="-15.0*cm"  />  </detector>

## RG-E: Sep 23th, 2024

Author: Antonio Radic

Experiment Description: Double target to study hadronization process. Liquid deuterium target and solid nuclear target exposed to the electron beam at the same time.
Solid targets inlcude Carbon, Aluminum, Copper, Tin, and Lead.

### Variations: 
1. Liquid Target (2cm cryocell):
2cm-lD2 - cryocell full with liquid Deuterium
2cm-lD2-empty - empty cryocell

2. Solid Target:
For solid selection, modify CAD subdirectory in gcard:
C - Band positioned with C foil in front of the beam
Al - Band positioned with Al foil in front of the beam
Cu - Band positioned with Cu foil in front of the beam
Sn - Band positioned with Sn foil in front of the beam
Pb - Band positioned with Pb foil in front of the beam
Empty - Band positioned with empty hole in front of the beam

### How to use it in the gcard
1. Choose LD2 variation:
Set it up in [RGE].gcard to choose full or empty deuterium cell:
<detector name="experiments/clas12/targets/target"         factory="TEXT" variation="2cm-lD2"/>

2. Choose Solid Target:
Change solid target in [RGE].gcard by choosing a subdirectory that contains CAD models for the requiered solid target configuration:
<detector name="experiments/clas12/targets/rge-dt/C/"  factory="CAD"/>

### gcard name format:
Format of gcard names for RGE (in clas12-config) have the following format:

target_text_rge_spring2024_[liquid-target]-[solid-target]-[vertex]-[magnetic-field].gcard

Where:

* [liquid-target] can be either be LD2 or Empty.

* [solid-target] can be either be C, Al, Sn, Cu, Pb or Empty.

* [vertex] corresponds to Liquid (liq), Solid (sol) or Reference foil (ref).

* [magnetic-field] corresponds to Inbending (In), Outbending (Out), or Zero field (Zero).

* Gcards for target testing located in clas12Tags have [vertex] and [magnetic-field] removed from the name.

### Notes
RGE gcards could be updated later depending on the GEMC updates and releases. Please verify them before using.

### Run numbers for each configuration
| Run number  | Configuration | Torus polarization | gcard variation name |
| :--------: | :-----------: | :-----------: | :-----------: |
20036-20039 | Empty-Empty | Zero Field | Empty-Empty-ref-Zero
20507| Empty-Empty | Inbending | Empty-Empty-ref-Inb
20017-20019<br>20070-20072 | Empty+C | Inbending | Empty-C-sol-Inb
20506|Empty+Al | Inbending | Empty-Al-sol-Inb
20269-20281 | Empty+Pb|Inbending | Empty-Pb-sol-Inb
20021-20034<br>20131-20176<br> | LD2+C | Inbending | LD2-C-sol-Inb<br>LD2-C-liq-Inb
20435-20493 | LD2+Al|Inbending | LD2-Al-sol-Inb<br>LD2-Al-liq-Inb
20177-20230 | LD2+Cu | Inbending | LD2-Cu-sol-Inb<br>LD2-Cu-liq-Inb
20331-20434 | LD2+Sn| Inbending | LD2-Sn-sol-Inb<br>LD2-Sn-liq-Inb
20041-20064<br>20074-20130<br>20232-20267<br>20282-20330<br>20494-20505 | LD2+Pb | Inbending | LD2-Pb-sol-Inb<br>LD2-Pb-liq-Inb
20508-20519 | LD2+C|Outbending | LD2-C-sol-Out<br>LD2-C-liq-Out
20520-20525 | LD2+Pb|Outbending | LD2-C-sol-Out<br>LD2-C-liq-Out

