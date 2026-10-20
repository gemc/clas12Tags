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

The following improvements are upcoming in the next release. The three active meshes in `cad/` use the
cured HTCC assets from `clas12-systems`; their original engineering inputs are retained in `cad_original/`.
The runtime copies in `../../experiments/clas12/htcc/cad/` contain the same active meshes.

| Mesh | Original triangles | Active triangles | Original boundary edges | Active boundary edges |
|------|-------------------:|-----------------:|------------------------:|----------------------:|
| `htccCone` | 18,818 | 6,000 | 144 | 0 |
| `htccMollerCone` | 6,232 | 5,866 | 0 | 0 |
| `htccMollerConeExt` | 1,748 | 1,748 | 0 | 0 |

The entry cone and extension are manifold. The Moller cone retains 24 non-manifold edges, reduced from 45
in the original with the current PyMeshLab topology check, and can still produce a Geant4 tessellated-solid
orientation warning. It remains closed, with its original bounds. The entry cone's bounds change by at most
0.74 mm after simplification; the extension retains its original bounds.

Names, Rohacell material, rotations, and survey shifts are retained for all three variations, including the
extension's additional 1 mm z shift. The existing GXML and SQLite CAD rows resolve the replacement meshes
without regeneration.

To reproduce the curing recipe, use a Python environment containing `pygemc` and `pymeshlab`, and run from
this directory:

```python
from pygemc.utilities import cure_mesh

for name, faces, intersections in (
    ("htccCone", 6000, False),
    ("htccMollerCone", 6000, True),
    ("htccMollerConeExt", 0, False),
):
    cure_mesh(f"cad_original/{name}.stl", f"cad/{name}.stl",
              target_faces=faces, remove_self_intersections=intersections, verbose=False)
```

Keep the cones' engineering openings; do not apply hole filling or Poisson reconstruction. Poisson
reconstruction inflated the Moller cone radius by about 53% in the original study. Regenerate the runtime
copies with the standard geometry-generation script after rebuilding the meshes. Mesh output can vary with
the PyMeshLab version.

### Validation and remaining contact

GEMC 6.2 with Geant4 10.7.4 initialized all three variations through both TEXT/CAD and SQLite/CAD using
the local CCDB database. Each variation matched all 537 native TEXT/SQLite rows and all three CAD placements.

The full default SQLite overlap check reported contact between `htccCone` and `htccEntryWindow`. An isolated
cone/window check with `CHECK_OVERLAPS=1000` and `RANDOM=12345` confirmed about 0.053 mm penetration for the
cured entry cone; the same check with the archived raw cone reported none. This contact remains unresolved
in the transferred mesh. The two Moller cones passed the default assembly overlap check.
