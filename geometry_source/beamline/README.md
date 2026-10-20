# CLAS12 Beamline



# Run Configurations

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| default          | 11             | 
| rgk_winter2018   | 5874           | 
| rgb_spring2019   | 6150           | 
| rgf_spring2020   | 11620          |
| rgc_summer2022   | 16043          |
| rgc_fall2022     | 16843          |
| rge_spring2024   | 20000          |

To build the geometry:

./beamline.pl config.dat




## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py beamline__geometry_default.txt        ../../clas12.sqlite beamline  11   default
$GEMC/api/perl/db_compare.py beamline__geometry_rgk_winter2018.txt ../../clas12.sqlite beamline  5874 default
$GEMC/api/perl/db_compare.py beamline__geometry_rgb_spring2019.txt ../../clas12.sqlite beamline  6150 default
$GEMC/api/perl/db_compare.py beamline__geometry_rgf_spring2020.txt ../../clas12.sqlite beamline 11620 default
$GEMC/api/perl/db_compare.py beamline__geometry_rgc_summer2022.txt ../../clas12.sqlite beamline 16043 default
$GEMC/api/perl/db_compare.py beamline__geometry_rgc_fall2022.txt   ../../clas12.sqlite beamline 16843 default
$GEMC/api/perl/db_compare.py beamline__geometry_rge_spring2024.txt ../../clas12.sqlite beamline 20000 default

````

## Apex CAD meshes

Upcoming in the next release. The lead fill has 1,440 triangles instead of 2,880; the hub is renamed
`Apex_Shield_Hub` and has 20,000 triangles instead of 36,354. Topology-preserving quadric decimation
retains the original openings and the hub's two components; sharp hub features are protected. Materials,
coordinates, placements, and all other beamline STL files are unchanged. `cad_original/` archives the
original engineering tessellations. Update custom GXML volume names from `Apex_Shield_PCAL_Hub` to
`Apex_Shield_Hub` so the CAD factory can find the renamed file.

The reproducible builder and GEMC3 benchmark are maintained in the owning `clas12-systems` repository:

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --output geometry_source/beamline/cad
```

Run the builder from this repository's root. Its mesh-health JSON records the original and optimized hashes,
topology, volumes, and bidirectional sampled surface distances. Shape deviation is below 0.05 mm in this
sampling; it is not a proven global bound. Refresh runtime assets through the normal geometry workflow
after rebuilding. The apex benchmark and CAD optimization note retain matched primaries, loading/memory
measurements, electron/hadron transport timings, and separate overlap diagnostics.

## Downstream tube meshes

Upcoming in the next release. The two downstream tube meshes retain their names, materials, coordinate frames,
and placements. Segment 1 is repaired by registering and bridging seven missing annular joins without
capping the bore, with seam vertices protected during decimation. The current mesh has 5,096 triangles
after the socket relief described below. Segment 2 is
reduced from 672 to 600 triangles.
Both outputs are closed, manifold tubes with no detected self-intersections or zero-area triangles.

The reduction is deliberately modest because the originals are already coarsely tessellated. Maximum
bidirectional sampled surface differences are 0.746 mm and 0.457 mm; these measurements are not global error
bounds. Segment 1 has no valid original volume; decimation and socket relief change its repaired reference
volume by -0.620987%. Segment 2 changes by -0.00170%. Both joint overlaps are resolved by the relief
described below; the engineering placements remain unchanged.
Raw originals are retained in `cad_original/`; quality statistics are in `cad/downstream_mesh_health.json`.

From this repository's root, regenerate with the builder maintained in `clas12-systems`:

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair downstream --output geometry_source/beamline/cad
```

The same repository's beamline benchmark accepts `--pair downstream`, uses matched 5 GeV primaries over
0.1--1.3 degrees, and records loading, memory, electron/hadron transport, and overlap/navigation diagnostics.
The CAD optimization note retains its measurements and reproducible inputs separately from the apex study.

## Adapter and torus exit shield

Upcoming in the next release.


`Torus_Beam_Tube_Reducer_2` is renamed `Beamline_Adapter_1` in every CAD variation and reduced from 528 to
526 triangles. `Torus_Exit_Shield_Casing` is reduced from 1,392 to 1,384 triangles. These engineering meshes
are already coarse, so reductions are deliberately small. The casing's 432 faces with a vertex within
1 mm of the lead fill are protected and verified to retain exactly the same vertex coordinates.
`Torus_Exit_Shield_Lead_Fill` is already clean at 384 triangles; it is retained byte for byte because even
one trial edge collapse displaced its surface by more than 1 mm near tight mating clearances.

All three retain their components, genus, closed manifold topology, bounds, materials, and placements.
No self-intersections or zero-area faces are detected. Maximum bidirectionally sampled deviations are
0.456 mm for the adapter and 0.5002 mm for the casing, below this group's 0.51 mm sampling guard; this is
not a proven global bound or the apex's 0.05 mm criterion. Volume changes are +0.000368% and +0.000188%.
The group decreases from 2,304 to 2,294 triangles (0.434%) and from 115,452 to 114,952 bytes.
`cad/exit_mesh_health.json` records the checks and the lead fill's retained original hash.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py --pair exit \
  --output geometry_source/beamline/cad
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair exit --executable /path/to/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/exit-benchmark --events 200 --repeats 5
```

The isolated three-volume benchmark uses matched 5 GeV primaries over 0.25--2.6 degrees and full azimuth.
Loading, transport, memory, and overlap diagnostics are retained separately. Given the small triangle
reduction, timing fluctuations must not be interpreted as substantial performance gains.

## FT adjuster material model


`adjuster1`, `adjuster2`, and `adjuster3` are replaced by one `ft_adjuster` STL and one CAD placement in
all nine variations that contain the trio. Their common `G4_STAINLESS-STEEL` material, passive transform,
and color are retained. Shape detail is deliberately simplified in favor of the amount of material.
The result is a closed 12-sided prism with 48 triangles instead of 3,800 (98.74% fewer), with its axis
through the reference union's centroid and the same 152.370 mm longitudinal span.

Two originals have nine-edge surface openings. Small patches establish a sealed reference before Boolean
union; their residual intersections are recorded, and that reference geometry is not published. The sealed
parts sum to 25,203.967 mm3; overlap removal gives a reference union of 24,922.570 mm3. Independent
inclusion-exclusion of the pairwise intersection volumes agrees within 0.00001%. This defines an estimated
material budget, not a certified engineering mass or response-equivalent shape. The final saved STL differs
from that union volume by -0.0000284%, has one closed manifold component with genus zero, and has no detected
self-intersections or zero-area faces. Original STLs are retained in `cad_original/` in clas12Tags.

`cad/adjuster_mesh_health.json` retains original hashes, reference defects, the material budget, and output
checks. The benchmark reconstructs either the original three CAD rows or their one-row replacement from
the common physical attributes, so it accepts a generated database from either state:

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair adjuster \
  --output geometry_source/beamline/cad
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair adjuster --executable /path/to/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/adjuster-benchmark --events 200 --repeats 5
```

The matched 5 GeV primaries cover 2.5--3.3 degrees and azimuths -95-- -85 degrees, directed toward the
off-axis adjuster. Loading, peak memory, transport, and overlap diagnostics are retained separately.
The replacement redistributes material and changes navigation; timing gains do not prove unchanged response.

## FT inner shield and flange


`innerShieldAndFlange` is renamed `FTInnerShieldAndFlange` in all ten applicable CAD variations and reduced
from 34,448 to 22,000 triangles (36.14% fewer). The tungsten-alloy material, common passive placement,
coordinate frame, and overall bounds are unchanged. Topology-preserving decimation retains the two closed
manifold surface components and aggregate genus 17, including the bore and mounting holes. The small
inward-oriented enclosed pocket is protected: all 474 of its original triangles remain at exactly the
same coordinates. No holes are filled, components removed, or surfaces reconstructed.

Maximum bidirectional vertex/edge/surface sampling gives a 0.0481 mm deviation, below the 0.05 mm guard.
This is a sampled maximum, not a proven global error bound. Total signed volume changes by -0.0000439%;
a separate component calculation confirms the pocket is unchanged and the main component changes by
-0.0000411%. The saved STL has no detected self-intersections or zero-area faces.
`cad/inner_shield_mesh_health.json` records hashes, topology, bounds, volumes, and sampled distances.
The original is retained under `clas12Tags/geometry_source/beamline/cad_original/`.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair inner_shield \
  --output geometry_source/beamline/cad
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair inner_shield --executable /path/to/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/inner-shield-benchmark --events 200 --repeats 5
```

The isolated one-mesh benchmark uses matched 5 GeV primaries over 0.25--3.0 degrees and full azimuth,
with the same physics and separate loading, transport, memory, and overlap diagnostics as earlier studies.
Its metadata and raw results are retained in the CAD optimization note; full-experiment performance and
response equivalence remain outside this benchmark.

## FT inner shield bolts


The nine copper fasteners `nut1`--`nut9` are renamed `FTInnerShieldAndFlange_Bolt1`--`Bolt9`.
Threaded shafts and hexagonal head details are replaced by smooth solid 24-sided shafts and round heads.
Each mesh has 192 triangles: 16,278 combined triangles become 1,728 (89.38% fewer).
The original copper volumes are matched individually to within 0.0001%, including float32 STL rounding.
Materials, colors, mothers, and passive placements remain unchanged. The inner tip is shortened by
0.15 mm to separate it from the shield's blind-hole end face; a slightly adjusted shaft radius restores
its copper volume. The head stays inside the original across-flats envelope, at the original shoulder
and outer end. This deliberate material redistribution does not preserve the original threaded shape.

All nine outputs are closed, manifold, singly connected solids with no detected self-intersections or
zero-area faces. Triangle collision and enclosed-point checks in both directions find no intersection
with the unchanged optimized shield. Vertex-to-surface distances in both directions are at least
0.15 mm; these sampled distances are not a certified global clearance bound. Full default construction
and a separate shield-plus-bolts fixture provide Geant4 overlap checks.

`cad/bolts_mesh_health.json` retains the original hashes and model dimensions. The engineering originals
are archived in `clas12Tags/geometry_source/beamline/cad_original/`. Reproduce with the mesh-enabled Python:

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py --pair bolts \
  --output geometry_source/beamline/cad
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/scripts/beamline_bolt_clearance.py \
  --meshes geometry_source/beamline/cad --output /tmp/bolt-clearance.json
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair bolts --executable /path/to/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/bolts-benchmark --events 200 --repeats 5
```

The isolated nine-bolt benchmark uses matched 5 GeV primaries over 1.3--3.0 degrees and full azimuth.
The shield is excluded from transport timing and included separately in clearance checks. Loading,
transport, memory, and diagnostics are reported in the CAD optimization note with the earlier studies.

## FT outer flange


`outerFlange` is renamed `FTOuterFlange` in all ten applicable CAD variations. Its twelve bolt tunnels
are closed, while the central opening is retained. The flat annular surfaces are retriangulated using
all original inner and outer rim vertices at both z faces. The bounds, rim coordinates, stainless-steel
material, color, mother, and passive placement remain unchanged. The placement retains its original
1272.77 mm z offset, which differs from the inner-shield and mount offsets.

Triangles fall from 2,132 to 836 (60.79% fewer), and bytes fall from 106,684 to 41,884. The mesh remains
one closed manifold component, with genus reduced from 13 to 1. No self-intersections or zero-area faces
are detected. Closing the holes adds 32,343.387159 mm³ of stainless steel, increasing volume by 8.296635%.
Retriangulation preserves the hole-filled reference volume within floating-point precision. Bidirectional
surface sampling differs from that reference by at most 0.0000148 mm; this is a sampled maximum.

The original engineering STL is archived in `clas12Tags/geometry_source/beamline/cad_original/`.
`cad/outer_flange_mesh_health.json` records topology, hashes, material-volume changes, and shape checks.
Reproduce in the mesh-enabled environment, which provides pygemc's bolt-hole removal utility:

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair outer_flange \
  --output geometry_source/beamline/cad
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair outer_flange --executable /path/to/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/outer-flange-benchmark --events 200 --repeats 5
```

The isolated flange benchmark uses matched 5 GeV primaries over 1.9--2.8 degrees and full azimuth.
Loading, memory, particle tracking, and overlap diagnostics are retained in the CAD optimization note.
Timing changes include the added material and changed shower histories from filling the bolt tunnels.

For a comparison at fixed material volume, provide the hole-filled, unreduced flange with
`--filled-reference`. The reference has 2,084 triangles and the optimized flange has 836, with matching
volume, bounds, and rim geometry. The note retains a separate five-repetition control with 2,000 events
per particle and the same physics, acceptance, placements, and fixed executable:

```shell
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair outer_flange \
  --filled-reference /tmp/filled.stl --executable /path/to/fixed/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/flange-filled-control --events 2000 --repeats 5
```

The control reference can be extracted from `hole_filled_reference/filled.stl` in the note's outer-flange
archive or regenerated with pygemc's `remove_holes.py` using the archived original and a 40 mm cutoff.
The control's `original` fixture label denotes this unreduced filled mesh, rather than the drilled original.

## FT outer mount


`outerMount` is renamed `FTOuterMount` in all ten applicable CAD variations. Four missing triangular faces
are repaired; the central passage and existing drilled openings are retained. The lower outer rim is
relieved by approximately 0.100 mm to clear `FTOuterFlange`, accounting for the original 0.5 mm difference
between their z placements. Adjacent sidewall facets interpolate toward unchanged upper vertices.
The mating facets are protected during simplification. Material, color, mother, and passive placement
are retained; the flange mesh is unchanged.

Triangles fall from 3,094 to 2,740 (11.44% fewer). The result is one closed manifold component with genus
11, no detected self-intersections, and no zero-area faces. Simplification differs from the relieved
reference by less than 0.05 mm under bidirectional vertex, edge, and surface sampling. The clearance relief
reduces volume by approximately 0.24924% against the sealed reference; the open engineering mesh has no
defined solid volume. `cad/outer_mount_mesh_health.json` records these references, hashes, and checks.

Placed-mesh triangle collision and containment checks find no mount/flange intersection. Clipping the
mount triangles to the flange's z range bounds the mount radius below the flange's minimum inner radius
by more than 0.035 mm. A separate 10,000-point Geant4 assembly check verifies the fit. The original mesh
is retained in `clas12Tags/geometry_source/beamline/cad_original/`.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair outer_mount \
  --output geometry_source/beamline/cad
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/scripts/beamline_mount_clearance.py \
  --mount geometry_source/beamline/cad/FTOuterMount.stl --output /tmp/mount-clearance.json
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair outer_mount \
  --executable /path/to/fixed/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/outer-mount-benchmark --events 200 --repeats 5
```

The isolated tracking benchmark uses matched 5 GeV primaries over 1.5--2.4 degrees and full azimuth.
Results, raw diagnostics, material changes, and full assembly checks are retained in the CAD optimization
note. Repairs and relief change transport boundaries, so timings are not attributed only to triangle count.

## FT inner shield

Upcoming in the next release. `taggerInnerShield` is renamed `FTInnerShield` with its original
tungsten material and passive placement. Its defective 44,122-triangle surface is rebuilt from the
measured tube/flange profile and reduced to 6,500 triangles (85.27% fewer). The 60 mm central bore,
665 mm length, two longitudinal grooves with rounded ends, and tube/flange fillets are retained.
All 26 flange through-holes, all conical recesses, face chamfers and counterbores, and the tube hole
are filled. Both flange faces are smooth flat annuli. This supersedes the earlier 13,500-triangle
version that retained blind flange recesses; a further 7,000 triangles are removed (51.85%).

The final surface is closed, manifold, and genus one, with no detected self-intersections or zero-area
facets. All 512 flat flange facets and the groove/corner faces are protected during simplification.
An independent check confirms complete planar annuli and 1,134 inside/outside probes with no recess
walls. The new mesh adds 0.436019% tungsten volume relative to the prior closed mesh. Simplification
alone changes the smooth reference volume by -0.000846%; maximum sampled deviation is 0.047853 mm.
The open engineering original has no defined volume. `cad/ft_inner_shield_mesh_health.json` records
the smooth reference, geometry checks, and hashes. The CAD optimization note preserves the earlier
study and separately reports this smooth-flange revision and its tracking comparisons.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair ft_inner_shield --output geometry_source/beamline/cad \
  --reference /tmp/ft-inner-shield-reference.stl
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair ft_inner_shield \
  --filled-reference /tmp/ft-inner-shield-reference.stl --executable /path/to/fixed/gemc \
  --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/ft-inner-shield-smooth-control --events 200 --repeats 5
```

For the incremental upgrade comparison, supply the archived 13,500-triangle prior mesh with
`--filled-reference` and describe it using `--baseline-description`; use a fresh output directory.
Matched 5 GeV primaries cover 0.7--2.7 degrees and full azimuth. Filling the recesses changes material,
so upgrade timings are reported separately from the smooth-reference simplification control.

## Moller cone

The tenth beamline study renames main-cone to moller_cone in nine source and runtime GXML variations and
nine GEMC2 SQLite CAD rows. The beamline_W tungsten material, color, passive 180-degree y rotation, and
run-dependent positions remain unchanged. Five placements use cone z = 1589.27 mm and overlap the
FTInnerShield axial interval; four use z = 1273.27 mm and are already separated from the shield. The current
smooth-flange FTInnerShield is unchanged. The raw engineering cone is archived before replacement.

The original contains 15,782 triangles and 302 boundary edges in eight surface loops: five on the outer
tapered wall and three on the inner cylindrical wall. Its open surface has no valid enclosed material
volume. Filling those openings follows the measured outer cone and inner cylinder profiles, preserving every
original face and vertex before clearance work. The closed hole-filled reference has 16,688 triangles. The
large central beam passage remains open. A full nominal axisymmetric reconstruction is avoided because the
engineering outer rings are coarsely tessellated; their existing bounds and facets provide the shape
reference.

The existing entrance counterbore, about 39.98595 mm radius, is widened with a protected 128-sided
cylindrical cut of radius 40.200001 mm. The cut ends at local cone z = -53.53 mm, 0.2 mm beyond the
overlapping shield tip at -53.73 mm. A 0.2 mm nominal radial allowance above the shield radius accounts for
the polygonal opening. Independent clipped-triangle bounds give a minimum cone opening radius of 40.187892
mm and maximum shield radius 40.000001 mm, proving at least 0.187891 mm radial separation throughout the
shared axial interval. Collision checks and bidirectional vertex containment find no intersection in all
nine placements; the nearest sampled vertex-to-surface distance is 0.199938 mm in the overlapping group and
199.109193 mm in the axially separated group.

The clearance reference has 11,616 triangles; protected simplification retains 1,964 joint, shoulder, and
corner facets and produces 5,000 triangles, 68.32% fewer than the engineering input. File size falls from
789,184 to 250,084 bytes. The final mesh is one closed manifold component of genus one, with no detected
self-intersections or zero-area facets and exactly unchanged outer bounds. Minimum triangle altitude is
0.000380430 mm. Maximum sampled bidirectional displacement from the clearance reference is 0.020048 mm,
below the 0.05 mm shape guard. The original input reproduces the final STL and both reference meshes byte
for byte.

Hole-filled reference volume is 5835559.232219 mm3; final volume is 5825708.437762 mm3. Counterbore relief
and simplification remove 0.168806% tungsten relative to the closed hole-filled reference. Simplification
alone changes clearance-reference volume by -0.0000002660%. No original mass difference is inferred from the
defective open input. Fifty-five independent material probes test the filled opening centres and the
retained central beam passage.

Raw/final median transport ratios are 2.200, 1.739, 1.574, 1.552 for electrons, protons, positive pions, and
neutrons respectively. The raw cone emits 26 GeomSolids1001 and 396 GeomNav1002 exception blocks across the
recorded processes. Its stuck-track recovery and invalid solid prevent attributing these ratios solely to
tessellation reduction. The final mesh emits no Geant4 exceptions. The clean repaired-reference/final
comparison gives ratios 1.638, 1.313, 1.402, 1.301 in the same order, with no exceptions in either case.
Ratios above one mean faster tracking. These isolated timings do not establish full CLAS12 speedup or
physics-response equivalence. Median startup simulation time changes from 0.777853 to 0.744276 s; peak
startup RSS changes from 137.08 to 122.14 MiB.

A separate cone/shield assembly test uses 10,000-point Geant4 overlap checking. The original cone gives five
overlap reports and one solid warning; the final assembly has no warnings or overlaps. Full default beamline
construction completes with no missing meshes or solid warnings, retaining four overlap reports at the
unrelated downstream tube/adapter joints. The earlier shield studies retain their historical overlap
measurements; this cone revision resolves that interference. Semantic comparisons pass all fifteen native
geometry and material variations and fourteen CAD variations against GEMC2.


Rebuild the cone and retain both references for material and repaired-reference timing comparisons:

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair moller_cone --output geometry_source/beamline/cad \
  --reference /tmp/moller-clearance-reference.stl \
  --repair-reference /tmp/moller-hole-filled-reference.stl
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/scripts/beamline_cone_clearance.py \
  --cone geometry_source/beamline/cad/moller_cone.stl \
  --shield geometry_source/beamline/cad/FTInnerShield.stl --output /tmp/moller-clearance.json
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair moller_cone \
  --executable /path/to/fixed/gemc --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/moller-upgrade --events 200 --repeats 5
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair moller_cone \
  --filled-reference /tmp/moller-clearance-reference.stl \
  --executable /path/to/fixed/gemc --database /tmp/beamline.sqlite \
  --originals geometry_source/beamline/cad_original \
  --output /tmp/moller-reference-control --events 200 --repeats 5
```

The builder reads the owning GXML placements and the current smooth-flange FTInnerShield. The archive
retains that unchanged shield, all placement inputs, both references, final and reproduced meshes,
geometry database fixtures, raw logs/time reports/primaries, and archived scripts. The original cone is
open and emits solid and stuck-track warnings; only the repaired-reference control isolates decimation.
The binary itself is not redistributed; its SHA-256 is recorded in both benchmark metadata files.

## Downstream socket clearance

Only Segment 1 is changed. Its entrance socket radius increases from 60.325 to 60.771702 mm through nominal
z = 5048.376367 mm, followed by a 1 mm transition back to the original bore. Two additional 24-vertex rings
replace one long wall band with three bands, adding 96 triangles. The downstream socket radius increases
from 70.6628 to 71.162277 mm over its existing downstream wall interval. Both sockets retain their angular
grids. The adapter, Segment 2, all outer bounds, materials, passive placements, and the open beam passage
remain unchanged.

The revised Segment 1 contains 5,096 triangles and 254,884 bytes, compared with 5,000 triangles and 250,084
bytes before relief. It remains one closed manifold genus-one component with no detected self-intersections
or zero-area triangles. Final volume is 6710837.897365 mm3, removing 0.604764% steel relative to the
previous closed mesh. Volume change against the original annularly repaired reference is -0.620987%. The
original engineering surface remains open and has no valid mass. Maximum sampled distance from that source
remains 0.745438 mm, within the existing 0.75 mm guard. The current builder reproduces the relieved STL byte
for byte.

Independent clipping of neighboring triangles to their shared axial intervals gives minimum clearance to all
48 socket-wall triangle planes of 0.100019 mm at the adapter and 0.100022 mm at Segment 2. Triangle
collisions and bidirectional vertex containment are zero for both pairs. All eleven source CAD
configurations containing the three volumes use the same identity placements, so the same joint checks apply
to each. The separate 10,000-point Geant4 assembly test gives eight overlap reports before relief and no
exceptions afterward. Full default beamline construction now finishes without missing meshes, solid
warnings, or overlap reports. These checks cover the tested configuration and do not certify every possible
complete detector assembly.

Previous/relieved median transport ratios are 0.981, 1.000, 1.008, 0.960 for electrons, protons, positive
pions, and neutrons respectively. Ratios above one denote faster tracking. The previous assembly produces 18
GeomNav1002, 4 GeomVol1002 exception blocks across the recorded processes; the relieved assembly produces 15
GeomNav1002 blocks. The remaining navigation warnings occur in the unchanged bellows region rather than
either relieved joint. Their z coordinates lie between 10177.906421 and 10281.864247 mm; all 1,741 triangles
intersecting the combined before/after warning interval are identical. Clean overlap checks therefore do not
establish warning-free tracking. These timings include overlap removal, local steel removal, and 96
additional facets. They measure the repair workload rather than a pure decimation gain, and do not establish
full CLAS12 performance or physics-response equivalence. The earlier study chapters and archives retain
their historical measurements.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --output geometry_source/beamline/cad --pair downstream
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/scripts/beamline_downstream_clearance.py \
  --meshes geometry_source/beamline/cad \
  --output /tmp/downstream-clearance.json
python3 ../clas12-systems/scripts/beamline_cad_benchmark.py --pair downstream_joints \
  --executable /path/to/fixed/gemc --database /tmp/beamline.sqlite \
  --originals /path/to/archive/previous --output /tmp/downstream-joint-benchmark --events 200 --repeats 5
```

## Moller cone tip

Upcoming in the next release. `cone-tip` is renamed `moller_cone_tip` in its four CAD configurations
(runs 5874, 11620, 18304, and 20000). Protected quadric decimation reduces 13,730 triangles to 5,000
(63.58% fewer), retaining one closed manifold genus-two component, both openings, exact bounds, and all
1,936 sharp-edge faces. No holes are filled. Maximum bidirectional sampled surface deviation is 0.0324 mm;
this is not a global error bound. Tungsten volume changes by -0.000486%, and materials and passive
placements are unchanged. The original is retained in `cad_original/`; the mesh-health report records hashes
and quality checks. The main-cone/tip overlap already exists with the original mesh and remains after this
optimization; complete affected configurations retain other source warnings.

The isolated five-seed benchmark uses 200 matched 5 GeV events per particle, 2.5--4.8 degrees, full azimuth,
FTFP_BERT, no field or optics, and one thread. Median tracking speedups are 1.659 for electrons, 1.133 for
protons, 1.177 for positive pions, and 1.159 for neutrons. All seed pairs are faster and isolated runs have no
Geant4 exceptions. These results do not establish full-experiment gains or detector-response equivalence.
The CAD optimization note retains raw results, full-assembly warnings, hashes, and reproduction inputs.


```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair cone_tip --output geometry_source/beamline/cad
```

## FT flange

Upcoming in the next release. `flange-assembly` is renamed `FTFlange` in runs 5874, 11620, 18304, and
20000. Its already-coarse closed annulus is reduced from 552 to 540 triangles (2.17% fewer), with the
central passage, exact bounds, two flat face planes, stainless steel, and passive placement retained.
The result remains one closed manifold genus-one component with no detected self-intersections or
zero-area faces. No holes are filled. Maximum bidirectional sampled deviation is 0.049822 mm; this
is not a global bound. Steel volume changes by -0.000109%. The original is archived in `cad_original/`,
and the mesh-health report retains hashes and quality measurements.

Five repetitions of 2,000 matched 5 GeV events per particle over 1.4--3.8 degrees give median tracking
ratios of 1.0018, 1.0001, 1.0003, and 0.9993 for electrons, protons, positive pions, and neutrons.
All isolated runs complete without Geant4 exceptions. The paired ranges span one, so this study does
not establish a tracking-speed gain. Existing inner/outer assembly overlaps and an open inner assembly
remain. The CAD optimization note retains complete diagnostics, raw timings, and reproducible inputs.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair ft_flange --output geometry_source/beamline/cad
```

## Inner Moller-cone extension

Upcoming in the next release. `inner-assembly` is renamed `moller-cone-extension-inner` in runs
5874, 11620, 18304, and 20000. Its 75 open boundary edges are the two rims of a radial port with a
missing wall. Stitching the 35- and 40-vertex rims adds 75 faces without moving original vertices
or capping the beam passage or either port. The closed reference has 18,132 triangles and genus
three. Protected decimation retains 7,297 sharp-edge and port-adjacent faces and reduces it to 12,500
triangles, 30.77% fewer than the raw 18,057-triangle mesh. Bounds, stainless steel, and passive
placements remain unchanged. The saved mesh is closed and manifold with no detected intersections
or zero-area faces; its maximum sampled deviation from the repaired reference is 0.015669 mm.
This is a sampled measurement, not a global bound. Decimation changes the repaired steel volume
by +0.000009303%; the open original has no valid solid volume. Originals and mesh-health evidence
are retained. Separate raw-upgrade and repaired-reference tracking comparisons are recorded in the
CAD optimization note, along with existing assembly overlaps and remaining full-configuration warnings.
The clean-reference tracking speedups are 1.261, 1.086, 1.144, and 1.095 for electrons, protons,
positive pions, and neutrons in the isolated five-seed sample; every seed pair improves without warnings.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair extension_inner --output geometry_source/beamline/cad --reference /tmp/inner-extension-reference.stl
```

## Moller-cone extension lead fill

Upcoming in the next release. This study renames `lead-shield` to `moller-cone-extension-lead-fill` in runs
5874, 11620, 18304, and 20000 in both repositories. The lead material, passive 180-degree y rotation, and
1273.27 mm z translation are retained. SQLite banks remain in `default`, selected by run number. The original
is archived, and all three installed optimized meshes are byte-identical.

The original is already a closed manifold solid with 10,594 triangles, one component, and genus two. Protected
quadric decimation reduces it to 8,000 triangles (24.4856% fewer), with 529,784 versus 400,084 stored bytes.
All 7,156 faces adjoining sharp edges above five degrees or any vertex within radius 48 mm retain their exact
triangle coordinates. This protects the full inner mating surface and adjacent end faces. The beam passage,
radial opening, and exact bounds remain. There is no hole filling or surface reconstruction. The result
retains its topology and has no boundary edges, non-manifold elements, detected intersections, or zero-area
triangles. Independent rebuilding reproduces its bytes.

Material volume changes from 11950334.138104 to 11950334.137844 mm³ (-0.0000000022%). Maximum bidirectional
vertex, edge, and surface sampled deviation is 0.00001998 mm, below the 0.05 mm guard. This sampled maximum is
not a proven global bound. Trials exceeding the shape, bounds, or volume guards are rejected.

The moller-cone extension lead fill retains its mating surface and openings with 24.49% fewer triangles.
Median isolated tracking ratios are 1.0826, 1.0795, 1.1226, 1.0882 for electrons, protons, positive pions, and
neutrons. Every paired measurement improves in this sample. Existing assembly overlaps remain.

## Moller-cone extension lead case

Upcoming in the next release. This study renames `outer-assembly` to `moller-cone-extension-lead-case` in runs
5874, 11620, 18304, and 20000 in both repositories. The stainless steel material, passive 180-degree y
rotation, and 1273.27 mm z translation are retained. SQLite banks remain in `default`, selected by run number.
The original is archived, and all three installed optimized meshes are byte-identical.

The original is already a closed manifold solid with 17,360 triangles, one component, and genus two. Protected
quadric decimation reduces it to 10,000 triangles (42.3963% fewer), with 868,084 versus 500,084 stored bytes.
All 9,105 faces adjoining sharp edges above five degrees or any vertex within radius 118 mm retain their exact
triangle coordinates. This protects the full inner mating surface and adjacent end faces. The beam passage,
radial opening, and exact bounds remain. There is no hole filling or surface reconstruction. The result
retains its topology and has no boundary edges, non-manifold elements, detected intersections, or zero-area
triangles. Independent rebuilding reproduces its bytes.

Material volume changes from 817759.770060 to 817759.420845 mm³ (-0.0000427038%). Maximum bidirectional
vertex, edge, and surface sampled deviation is 0.00678680 mm, below the 0.05 mm guard. This sampled maximum is
not a proven global bound. Trials exceeding the shape, bounds, or volume guards are rejected.

The moller-cone extension lead case retains its mating surface and openings with 42.40% fewer triangles.
Median isolated tracking ratios are 1.0529, 1.0377, 1.0098, 1.0198 for electrons, protons, positive pions, and
neutrons. Some paired ranges include one; those particle samples do not establish a consistent gain. Existing
assembly overlaps remain.

## Moller-cone extension tungsten add-on

Upcoming in the next release. `outer-cone` is renamed `moller-cone-extension-tungsten-addon` in
runs 5874, 11620, 18304, and 20000. Bridging the 33- and 35-vertex rims restores a missing inclined
radial-port wall with 68 triangles while preserving all original vertex and triangle coordinates.
The beam passage and ports remain open. The repaired reference has 27,846 triangles and genus five.
Protected decimation retains 9,154 port, sharp-feature, and mating-interface faces and reduces the
mesh to 12,000 triangles, 56.80% fewer than the raw source. Bounds, tungsten material, and passive
placement are retained. Sampled deviation from the repaired reference is 0.012837 mm, and volume
changes by -0.0000046193%. The result is closed and manifold without detected intersections or
zero-area triangles. The main-cone mesh hash guards mating-face selection. The CAD optimization
note retains separate raw-input and repaired-reference tracking comparisons, geometry checks,
existing assembly overlaps, all raw timings, and reproducible inputs.

```shell
/Users/ungaro/venv/pygemc/bin/python ../clas12-systems/geometry_src/beamline/build_cad_meshes.py \
  --pair extension_tungsten --output geometry_source/beamline/cad --reference /tmp/tungsten-extension-reference.stl
```

## FT/cone joint clearances

Upcoming in the next release. This October 16 revision corrects the remaining FT/Moller-cone interfaces after
the individual mesh studies. Five meshes receive local material-removing operations: the inner extension, lead
fill, lead case, main cone, and tungsten add-on. FTInnerShield, FTFlange, and the cone tip remain
byte-identical. Placements, passive rotations, materials, names, and run keys are unchanged. All SQLite banks
remain in `default`, indexed by run number.

The inner-extension bore clears the placed FT shield, which is offset -369.73 mm in the common cone frame. Its
end is relieved around the unchanged flange bore. The lead-fill bore clears the inner extension. A scaled
convex envelope of the pre-clearance lead fill supplies at least 0.02002 mm plane clearance before final
casing simplification; a separate local cutter clears the unchanged flange. This envelope reduces casing
material loss from 4.4702% in a rejected circular-envelope trial to 1.2093%. The main cone receives a short
stepped relief around the inner-extension shoulder and a profiled opening around the cone tip. Its upper face
moves from z=712.002991 to 711.950012 mm. The add-on bore clears the main cone by a nominal 0.10 mm radial
profile margin. The health report retains every cutter profile and input hash.

Local FT/cone joint reliefs clear all eight checked interfaces while retaining the shield, flange, and cone
tip. Five meshes lose 0.119--1.209% material by volume. All affected complete configurations construct without
exceptions, and final corrected tracking runs are clean. Isolated tracking ratios 0.8568, 0.8541, 0.8465,
0.8920 describe the eight-part clearance revision; they are not pure decimation gains.

From the owning clas12-systems repository, run this pass last after reproducing individual mesh groups. Inputs
are archived in `cad_original/ft_joint_inputs_20261016/`; earlier shape and timing studies remain historical.
The current mesh-health reports retain their previous optimization records and reference the final joint
report.

```shell
/Users/ungaro/venv/pygemc/bin/python geometry_src/beamline/build_cad_meshes.py \
  --pair ft_joints --reference /tmp/ft-joint-case-reference.stl
python3 scripts/beamline_cad_benchmark.py --pair ft_joints --runno 5874 \
  --executable /path/to/fixed/gemc --database geometry_src/beamline/gemc.db \
  --originals ../clas12Tags/geometry_source/beamline/cad_original/ft_joint_inputs_20261016 \
  --output /tmp/ft-joints-benchmark --events 200 --repeats 5
```
