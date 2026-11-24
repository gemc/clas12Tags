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

Enable tile efficiency with `-DETECTOR_INEFFICIENCY=1`. GEMC reads
`/calibration/mvt/bmt_tile_efficiency` using the real run number,
`DIGITIZATION_VARIATION` and optional `DIGITIZATION_TIMESTAMP`. Before transport,
it checks the single `RUNNO` or every entry in `RUN_WEIGHTS`, including runs
allocated zero events. The startup log and job summary give the efficiency
request and CCDB assignment ID for each run.

`RUN_WEIGHTS` parsing accepts only complete run-number and weight pairs. This
fixes the old loop, which could reuse stale or uninitialised values after a
failed read at the end of the file.

Each assignment has 18 rows. Its columns are integer `sector` (1–3), integer
`layer` (1–6), integer `component` (0 for the whole tile), and double
`efficiency` (0–1 inclusive). Each sector/layer pair occurs once. Missing or
invalid constants stop the job. For studies that explicitly permit a missing
efficiency table or assignment, set `-BMT_ALLOW_MISSING_EFFICIENCY=1`. This
gives powered tiles efficiency 1 and unpowered tiles efficiency 0 for that run.
GEMC logs each fallback. `BMT_ALLOW_MISSING_EFFICIENCY` covers only the
efficiency table. With efficiency enabled, a missing drift- or strip-voltage
assignment still aborts startup, even with the fallback enabled.

### Measuring a tile efficiency

For one run and tile, divide the number of eligible charged tracks with at least
one matched strip signal by the number of eligible charged tracks crossing the
active area. Count a given track once per tile, including a track that revisits
the tile. Use the following reference sample when extracting probabilities from data.

- Select well-reconstructed charged tracks using an independent track seed and
  fit that exclude hits from the tile under test. Extrapolate to the active gas.
  Require the predicted intercept and its uncertainty to lie inside the fiducial
  area. Record the track-quality and fiducial cuts with the assignment.
- Require a crossing capable of producing ionization. In GEMC at least one step
  must produce one or more electrons (`int(1e6 * Edep_MeV / w_i_eV) > 0`) on
  a geometrically valid strip. In data use the reference track's path length
  and expected ionization to select this sample independently of tile readout.
  If the target production applies a BMT strip mask, exclude crossings whose
  predicted signal falls entirely on dead or masked strips. Use the same mask
  in reconstruction and efficiency extraction. This BMT digitizer does not
  apply a strip mask merely by setting `HARDWARESTATUS=1`.
- Count a success when at least one eligible strip signal matches the predicted
  crossing. Fix and record the spatial and timing windows, channel mask and
  ionization selection. Use the same cuts for data and MC.
- Use the run's drift and strip voltages from `/calibration/mvt/bmt_voltage`
  and `/calibration/mvt/bmt_strip_voltage`. If either is zero, exclude the
  tile-run from the measurement and store efficiency 0. A positive entry on an
  unpowered tile stops GEMC. Include losses at reduced, nonzero voltage in the
  measured efficiency. GEMC uses these voltages as on/off conditions. With the
  efficiency model disabled, GEMC reads drift voltage and always uses nominal
  strip voltage (520 V). A missing drift assignment in that mode leaves all
  tiles unpowered and prints a warning.

### Digitization and truth

Within an event, every step and strip from the same Geant4 track on a tile
shares one acceptance decision. On a shared strip, `BMT::adc` uses only
accepted tracks' deposits. Integrated `MC::True` describes the Geant4 hit
before readout and retains its full deposit, including contributions from tracks
rejected on that strip. Imported background hits bypass the efficiency decision.
With efficiency enabled a zero-efficiency tile emits no simulated ADC rows,
including the former empty rows with component −1 and ADC 0.

For production with pre-readout truth, include `bmt` in `INTEGRATEDRAW` and
set `SKIPREJECTEDHITS` to 0 in the gcard. The default value 1 omits fully
rejected hits from integrated truth. GEMC warns when digitizing BMT output
with efficiency enabled and this setting.

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
    -RUNNO=18305 -DIGITIZATION_VARIATION=rgd_fall2023_mc -DETECTOR_INEFFICIENCY=1 -SKIPREJECTEDHITS=0 \
    '-BEAM_P=mu-, 2*GeV, 80*deg, 90*deg' '-SPREAD_P=0*GeV, 0*deg, 0*deg' \
    '-OUTPUT=hipo, bmt-efficiency.hipo'
```

From the repository root, run the end-to-end regression with GEMC, the CCDB
CLI, sqlite3 and coatjava's `run-groovy` on PATH. Supply a calibration snapshot
covering run 10000 and runs 18305–18307 before addition of the efficiency table. The script
creates its own writable copy and prints the directory containing the HIPO files
and logs.

```sh
ci/bmt_efficiency/run.sh /path/to/clas12-calibration.sqlite
```
