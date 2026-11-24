# Geometry 



The geometry consists of central barrel (BMT) and a forward one (FMT) of micromegas detectors.

# Run Configurations

| variation        | SQL / CCDB Run | Configuration                                     |
|------------------|----------------|---------------------------------------------------|
| default          | 11             | BMT, 6 FMT layers                                 |
| rga_spring2018   | 3029           | BMT, 6 FMT layers                                 |
| rga_fall2018     | 4763           | BMT, no FMT                                       |
| rgf_spring2020   | 11620          | no BMT, 3 FMT layers, slim                        |
| rgm_fall2021_H   | 15016          | BMT, 3 FMT layers, slim                           |
| rgc_summer2022   | 16000          | BMT, no FMT                                       |
| rgd_fall2023     | 18305          | BMT, 3 FMT layers, slim                           |
| rgk_fall2023     | 19200          | BMT, no FMT                                       |
| rge_spring2024   | 20000          | BMT, 3 FMT layers, slim                           |
| rgl_spring2025   | 21000          | no BMT, no FMT                                    |
| michel_9mmcopper | 30000          | BMT, 3 FMT layers slim, modified copper thickness |


To build the geometry:

````./micromegas.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database


# Z positions

The z positions of `BMT` are determined by these parameters:

- BMT_endPCB_zpos
- BMT_zpos_layer1
- BMT_zpos_layer2
- BMT_zpos_layer3
- BMT_zpos_layer4
- BMT_zpos_layer5
- BMT_zpos_layer6


The z positions of `FMT` are determined by these parameters:

- FMT_mothervol_zmin
- FMT_mothervol_zmax


To match the positions assigned in the clas12-config gcards of BMT and FMT,
the spring2018 parameters have been subtracted by -1.94 cm. All the remaining
non default ones by -3cm.

## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py micromegas__geometry_rga_spring2018.txt ../../clas12.sqlite micromegas  3029  default
$GEMC/api/perl/db_compare.py micromegas__geometry_rgf_spring2020.txt ../../clas12.sqlite micromegas  11620 default
$GEMC/api/perl/db_compare.py micromegas__geometry_rgm_fall2021_H.txt ../../clas12.sqlite micromegas  15016 default
````

<br/>

---

## BMT tile hit efficiency

Enable the BMT efficiency model with GEMC's `-DETECTOR_INEFFICIENCY=1`. The BMT
digitizer reads `/calibration/mvt/bmt_tile_efficiency` for the event's run number,
`DIGITIZATION_VARIATION` and `DIGITIZATION_TIMESTAMP`. Both `RUNNO` and
`RUN_WEIGHTS` use this lookup. GEMC prints the assignment request when it loads
the table. With the switch off (the default), BMT skips the lookup. If CCDB
returns no assignment with the switch on, GEMC reports the request and uses
unit efficiency for that run.

Each assignment has 18 rows. The columns, in order, are integer `sector` (1–3),
integer `layer` (1–6), integer `component` (0 for the whole tile), and double
`efficiency` (0–1). Each sector/layer pair occurs once. A malformed assignment
stops digitization. Use a new CCDB assignment with its own run range to supply
measured probabilities later.

The probability applies to an otherwise detectable signal. In one event, all
steps and strips from a Geant4 track on a tile share one decision. This includes
a track revisiting the same tile. If tracks share a strip, its ADC uses the
accepted tracks' energy deposits. Imported background hits bypass this model.
Set `-SKIPREJECTEDHITS=0` to retain rejected simulated hits in integrated truth
output for efficiency studies.

### Local test assignment

Run these commands from the repository root with the CCDB CLI available.
Use a fresh local copy of your calibration snapshot and a CCDB user defined in
that snapshot. The example assigns synthetic probabilities only to run 18305 in
the RGD MC variation.

```sh
cp /path/to/clas12-calibration.sqlite bmt-test.sqlite
export CCDB_CONNECTION="sqlite:///$PWD/bmt-test.sqlite"
export CCDB_USER="$USER"
table=/calibration/mvt/bmt_tile_efficiency
ccdb mktbl "$table" -r 18 sector=int layer=int component=int efficiency=double
ccdb add "$table" -v rgd_fall2023_mc -r 18305-18305 \
    geometry_source/micromegas/ccdb/bmt_tile_efficiency_test.txt
ccdb dump "$table:18305:rgd_fall2023_mc"
```

To generate a micromegas-only sample with the modified GEMC, run the text
geometry card from its detector directory. Sector 2, layer 2 has probability
zero in this fixture, and sector 2, layer 3 has probability 0.50.

```sh
cd experiments/clas12/micromegas
gemc micromegas_text_rgd_fall2023.gcard -USE_GUI=0 -N=1000 \
    -RUNNO=18305 -DIGITIZATION_VARIATION=rgd_fall2023_mc -DETECTOR_INEFFICIENCY=1 \
    '-BEAM_P=mu-, 2*GeV, 80*deg, 90*deg' '-SPREAD_P=0*GeV, 0*deg, 0*deg' \
    '-OUTPUT=hipo, bmt-efficiency.hipo'
```
