# CLAS12 Magnets


The solenoid is created using Geant4 native volumes. 
The torus magnets has a CAD model that is imported in gemc and a Geant4 native volumes version as well.


Upcoming in the next release: the duplicate-shielding cleanup left 51 meshes before later optimizations. The
nine `DSShield*` meshes and `apex` have been removed because this shielding belongs to the beamline system.
Load the beamline alongside magnets to retain it. That removal reduced triangles from 148,940 to 132,230. The
subsequent downstream and upstream plate/jacket optimizations leave 126,778 triangles. Regenerate the SQLite
database after updating the CAD inputs.

`DownstreamShieldingPlate` and `DownstreamVacuumJacket` retain their original names and separate
placements. The plate fills eight through-holes and uses 508 instead of 1,380 triangles; the jacket
fills six blind bolt recesses and uses 556 instead of 2,392. Both retain their main apertures, rims,
bounds, hexagonal step, and 32.83203125 mm axial gap. Together they have 71.79% fewer triangles and
0.56658% more signed material volume. Original inputs are retained under `cad_original/`; the
reproducible builder belongs to `clas12-systems/geometry_src/magnets`.

`UpstreamShieldingPlate` and `UpstreamVacuumJacket` also retain their names and separate placements.
Their eight through-holes and six blind bolt recesses are filled, with 508 and 1,004 triangles
instead of 1,380 and 2,876 (64.47% fewer together). Main apertures, the stepped bore, outer rounded
features, bounds, and the 42.87805176 mm gap remain; all 894 non-cap/non-pocket jacket faces are
retained. Signed volume increases by 2.27163% for the plate and 0.52667% for the jacket.

## Shared vacuum jackets

Upcoming in the next release: all jacket names use `vacuumJacket` with sector/side suffixes. The `a` and `b`
jackets have different outlines and holes, so they retain distinct sources. `vacuumJacket2a`,
`vacuumJacket4a`, and `vacuumJacket5a` copy `vacuumJacket`; `vacuumJacket3b`, `vacuumJacket4b`, and
`vacuumJacket6b` copy `vacuumJacket1b`, with exact sector rotations. The four original `vacuumJacket2b`,
`vacuumJacket3a`, `vacuumJacket5b`, and `vacuumJacket6a` meshes remain separate: three preserve
nanometre-sensitive plate contacts, while `vacuumJacket6a` also contains an additional disconnected component.

Every hole, countersink, buried step, and narrow slot is retained. The two optimized source meshes preserve
all protected hole triangles exactly, reducing 8,388 to 8,384 facets and 7,560 to 7,556. The main gain is
sharing: the jacket group falls from 93,726 to 47,934 unique facets (48.86% fewer). All 12 placements remain;
finer canonical tessellations increase placed facets to 95,754. Total signed steel volume changes by
-0.000337%. After jacket sharing, magnets had 33 STL files and 74,830 unique facets for 39 CAD placements.

Export tessellations differ slightly within each family. Fitted circular hole parameters agree within 0.0001
mm; sampled polygonal surfaces differ by up to 0.27 mm. Protected hole geometry is unchanged in the canonical
sources. Dense assembly checks find no new overlap pair with the retained exceptions. Existing assembly
overlaps remain. GEMC2 now keeps the native copies in `magnets` alongside the solenoid.
GEMC3 keeps the source meshes and copies in the single `magnets` system.

## Torus coils

Upcoming in the next release: `coil1` becomes `coil`; `coil2` through `coil6` copy its unchanged STL.
All six copper coils match under exact 60-degree sector rotations within 0.000225 mm. Two exports use
the alternate diagonal on one planar side quadrilateral; the boundary and surface are equivalent.
Every opening and all 1,016 canonical facets remain. Removing any contour vertex would change the
profile, so sharing preserves the existing curved surfaces instead of decimating them further.

Unique coil facets fall from 6,096 to 1,016 (83.33% fewer); six placements still contain 6,096 facets.
Signed copper volume changes by -0.000011563%. After coil sharing, magnets had 28 STL files and
69,750 unique facets for 39 CAD placements. GEMC2 then used 28 CAD sources and 11 native `magnets_copies`
rows per run; GEMC3 kept all 39 placements in `magnets_cad`.

The timing study uses `--run-manager Serial --keep-going`. Both tasking and serial attempts encountered
duplicate-isotope registration errors (`PART122`), including with the original geometry. The note reports
completed matched pairs separately and retains every failed run; a complete tracking comparison remains limited.

## Hub covers

Upcoming in the next release: `Plate1` through `Plate6` become `hubCover1` through `hubCover6`.
The plain `hubCover1` mesh supplies copies 2, 4, and 5; the holed `hubCover3` mesh supplies copy 6.
Both source STLs are unchanged, preserving every surface, the main hole, and all 12 or 150 facets.
Exact sector rotations match the plain covers within 0.00000554 mm and the holed pair within numerical
roundoff. Alternate diagonals on flat faces preserve the same boundaries and surfaces.

Unique cover facets fall from 348 to 162 (53.45% fewer), while six placements retain 348 placed facets.
After hub-cover sharing, magnets had 24 STL sources with 69,564 unique facets for 39 CAD placements.
GEMC2 then used 24 CAD sources and 15 native `magnets_copies` rows per run. Signed aluminum volume is
unchanged to floating-point precision. Original engineering files remain in `cad_original/`.

## Hub shields

Upcoming in the next release: `Shield2` becomes `hub_shield`, supplying copies `hub_shield3` through
`hub_shield6`. The two different end profiles retain their own meshes as `hub_shield1` and `hub_shield7`.
The five middle exports have identical mapped connectivity and agree within STL rounding after axial
translations. All holes, radial contours, steps, and facet connectivity remain; both end STLs are unchanged.

Recentring the shared mesh reduces axial coordinate rounding. Its far faces shorten by 0.000059326 mm,
avoiding artificial overlaps at the nominal 304.8 mm pitch; final vertices differ from the engineering
placements by at most 0.000146485 mm. Positions retain three decimal places and rotations remain integer.

Unique shield facets fall from 4,146 to 1,594 (61.55% fewer), with 4,146 placed facets across seven volumes.
Signed tungsten-alloy volume changes by -0.000002416%. After hub-shield sharing, magnets had 20 STL sources
and 67,012 unique facets for 39 CAD placements; GEMC2 uses 20 CAD sources and 19 native `magnets`
rows per run.

## Cold hub

Upcoming in the next release: `Hub001` becomes `ColdHub` in all three configurations and both engines.
Every opening, material, bound, and passive placement remains. Positions use three decimal places.

The mesh closes two microscopic export slivers, reorients 13 faces, and retriangulates seven collinear
junctions without moving their vertices. This removes six boundary edges, seven degenerate triangles,
and eight intersecting faces. The result is one closed manifold component of genus 34.

Conservative edge collapses retain all holes and reduce 12,600 facets to 12,548 (0.41% fewer).
Surviving vertices retain their original coordinates; the largest local plane deviation is 0.000053917 mm.
Bidirectional surface checks sample more than 206,000 points per direction and find deviations below
0.000036 mm. Bounds are unchanged; volume differs from the repaired reference by less than 1e-9%.
Magnets now uses 20 STL sources, 66,960 unique facets, and 39 placements. The original is archived separately.

## Bore tubes

Upcoming in the next release: `CenterTube` becomes `BoreCenterTube` in all three configurations and both
engines. `BoreShield` and `WarmBoreTube` retain their names. All three STLs remain byte-identical to their
engineering exports, preserving every profile, bore, bound, and material volume.

The meshes are already closed manifold components of genus one, with no intersecting faces. Every vertex
is a required corner on an inner or outer end rim. Euler's relation gives `F = 2V` for these closed genus-one
triangulations; removing facets would require removing rim corners and changing the profiles.

| Volume | Original facets | Retained facets | Reduction |
|---|---:|---:|---:|
| BoreShield | 356 | 356 | 0% |
| BoreCenterTube | 406 | 406 | 0% |
| WarmBoreTube | 368 | 368 | 0% |
| Total | 1,130 | 1,130 | 0% |

No simulation speedup is established for this unchanged geometry; no new timing benchmark was run.
All nine GEMC3 and GEMC2 SQLite/TEXT construction checks pass for runs 11, 3029, and 4763, and semantic
comparison matches all three CAD configurations. Name-normalized database rows and identical mesh hashes
confirm that the physical placements and clearances are unchanged. Existing assembly overlaps remain.
Magnets still uses 20 STL sources, 66,960 unique facets, and 39 CAD placements.

## Consolidated geometry banks

Upcoming in the next release: the native system is `magnets`; its copper volume retains the name
`solenoid`. The 19 native `CopyOf` rows now share that bank. Load native `magnets` and the 20 source
meshes in `magnets_cad`; the separate copy bank and its TEXT files are retired.
The 40 physical volumes retain all names, placements, materials, and STL shapes. Regenerate SQLite and
TEXT output, then refresh runtime copies and cards. The local tungsten material matches the beamline alloy.

GEMC3 uses one SQLite `magnets` system containing the native solid, CAD sources, and copies. Historical
copy-bank names in the studies below refer to archived configurations. No facets are removed here and
no additional simulation speedup is established.

# Run Configurations

The magnets bank has default, rga_spring2018, and rga_fall2018 configurations because the physical solenoid
position changes. The native torus builder remains disabled.

| variation        | SQL / CCDB Run | 
|------------------|----------------|
| default          | 11             | 
| rga_spring2018   | 3029           | 
| rga_fall2018     | 4763           | 

To build the geometry:

./magnets.pl config.dat


## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py magnets__geometry_default.txt        ../../clas12.sqlite magnets   11   default
$GEMC/api/perl/db_compare.py magnets__geometry_rga_spring2018.txt ../../clas12.sqlite magnets   3029 default
$GEMC/api/perl/db_compare.py magnets__geometry_rga_fall2018.txt   ../../clas12.sqlite magnets   4763 default
```