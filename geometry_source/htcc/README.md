# Run Configurations

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| default        | 11             | 
| rga_spring2018 | 3029           | 
| rga_fall2018   | 4763           | 

To build the geometry:

````./htcc.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database

## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py htcc__geometry_default.txt       ../../clas12.sqlite htcc  11   default
$GEMC/api/perl/db_compare.py htcc__geometry_rga_spring2018.txt ../../clas12.sqlite htcc  3029 default
$GEMC/api/perl/db_compare.py htcc__geometry_rga_fall2018.txt   ../../clas12.sqlite htcc  4763 default
````

<br/>

---

## CAD meshes

Upcoming in the next release: the engineering Moller cone and collar are united into one closed manifold STL,
resolving the tessellated-solid orientation warning. All source and runtime meshes match the GEMC3 assets. The
archived engineering inputs remain unchanged.

| Mesh | Engineering facets | Active facets | Boundary edges | Non-manifold edges |
|---|---:|---:|---:|---:|
| htccCone | 18,818 | 6,000 | 0 | 0 |
| htccMollerCone | 6,232 | 6,902 | 0 | 0 |
| htccMollerConeExt | 1,748 | 1,748 | 0 | 0 |

The replacement starts from the unchanged archived engineering export. Only the collar's 45 shared ring
vertices move radially inward by 0.0001 mm, resolving the zero-width seam for an exact Boolean union.
Intersection vertices that coincide after binary-STL rounding are welded at 0.0002 mm; null and duplicate
faces are removed, winding is made coherent, and faces are ordered deterministically. No Poisson
reconstruction, engineering-hole filling, or bore cap is applied. Repeated processes reproduce the final STL
and audit report byte for byte with the recorded software versions.

The final mesh has 3,451 vertices and 6,902 facets in one closed manifold component of genus one. It has zero
boundary edges, non-manifold edges or vertices, degenerate triangles, or detected intersecting faces. All six
engineering bounds remain identical. A final-to-engineering surface comparison samples 153,451 points and
finds a maximum distance of 0.000096786 mm. The reference includes both engineering surfaces, including
internal contact faces; this is a one-direction sampled comparison, not a global distance proof. The main bore
remains outside the solid at all 200 tested axial points in direct Geant4 classification.

The repaired mesh replaces the former 5,866-facet active Moller cone, adding 1,036 facets. The entry cone and
extension remain byte-identical at 6,000 and 1,748 facets. Total active HTCC CAD facets therefore rise from
13,614 to 14,650; this is still 45.33% fewer than the 26,798 engineering facets. This update repairs the
material geometry and winding; no new repeated loading or tracking benchmark was run, and no simulation
speedup is assigned to it.

All nine repaired native-plus-CAD initializations succeed for runs 11, 3029, and 4763: GEMC3 with Geant4
11.3.2, and GEMC2 SQLite/CAD and TEXT/CAD with Geant4 10.7.4. Every repaired process has zero GeomSolids
warnings. The GEMC3 fixtures explicitly select their named survey variations and require all 541 constructed
rows including the world. Direct Geant4 11.4.3 solid checks accept all 6,902 facets without rejection or solid
warnings; the unchanged other two meshes also pass. Native comparison matches 537 geometry and eight material
rows per configuration, and nine CAD placements match in name, material, passive rotation, and survey shift.
All four active source/runtime mesh trees are synchronized, and engineering originals are unchanged.

The existing contact between htccCone and htccEntryWindow is separate from the Moller repair and remains
visible in some GEMC2 overlap checks. No sampled overlap warning involving the repaired Moller cone is present
in these nine logs. Successful construction and sampled checks do not establish full particle-navigation or
detector-response equivalence.

The builder now reads archived engineering inputs instead of repeatedly processing active CAD meshes.
From this directory, rebuild only the Moller cone with the mesh-enabled Python environment:

```shell
<mesh-python>/python3 ../../../clas12-systems/geometry_src/htcc/build_cad_meshes.py \
  --mesh htccMollerCone --source cad_original --output cad
```

Refresh experiments/clas12/htcc/cad/ afterward. Placements, materials, all three variations, and the
extension's additional 1 mm z shift need no database regeneration. Do not substitute generic hole filling
or Poisson reconstruction for the dedicated cone/collar union.
