# Geometry

The geometry consists of 36 elliptical mirrors, 36 hyperbolic mirrors
and 36 PMTs.

The parameters are created by the mirrors.C macro.

# Run Configurations

| variation      | SQL / CCDB Run | 
|----------------|----------------|
| default        | 11             | 
| rga_spring2018 | 3029           | 
| rga_fall2018   | 4763           | 
| rgb_spring2019 | 6150           | 
| rgb_spring2020 | 11323          | 
| rgm_fall2021_H | 15016          | 

To build the geometry:

````./ltcc.pl config.dat````

This will:

1. create the text based DB geometry files, with variation in the filenames
2. add detector run entries to the ../../clas12.sqlite database

## Geometry comparison:

To compare the two databases (TEXT and SQLITE) the script ` $GEMC/api/perl/db_compare.py` can be used:

````
$GEMC/api/perl/db_compare.py ltcc__geometry_default.txt        ../../clas12.sqlite ltcc  11   default
$GEMC/api/perl/db_compare.py ltcc__geometry_rga_spring2018.txt ../../clas12.sqlite ltcc  3029 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rga_fall2018.txt   ../../clas12.sqlite ltcc  4763 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rgb_spring2019.txt ../../clas12.sqlite ltcc  6150 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rgb_spring2020.txt ../../clas12.sqlite ltcc 11323 default
$GEMC/api/perl/db_compare.py ltcc__geometry_rgm_rgm_fall2021_H.txt ../../clas12.sqlite ltcc 15016 default
````

<br/>

---


TODO:

- Add focal point spheres for debugging purposes
- Generalize material and presence in a single file and use it for all LTCC components

CAD Notes:

- The following CAD changes are upcoming in the next release.
- Sector 3 contains the mesh-backed `backwall`, `rightwall`, `leftwall`, and `nose` source volumes.
- The other enabled sectors reuse those sources through `CopyOf` placements in `ltcc_frame.pl`.
- The cured and decimated Winston-cone meshes are reused for segments 1 through 17 on both sides.
- The unmodified engineering drawings used to derive the active meshes are retained in `original_drawings/`.

## CAD performance comparison

The macOS benchmark compares an earlier revision with the current LTCC data using the same GEMC executable.
It also tests the earlier geometry with only the three optimized Winston-cone meshes substituted, to separate
that change from the new frame and sector mothers. The benchmark uses an isolated LTCC detector, zero magnetic
field, no event output, and a local CCDB database. These conditions measure software performance rather than
CLAS12 background rates or detector-response equivalence.

After loading `gemc/dev`, run from the repository root:

```shell
export LTCC_DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH"
python3 ci/ltcc_cad_benchmark.py --baseline-ref ea3625f \
    --ccdb geometry_source/coatjava/etc/data/sqlite/ccdb.sqlite \
    --output /private/tmp/ltcc-comparison --events 1000 --repeats 5 --overlaps \
    --restore-baseline-hardware --fixed-primaries
```

For matched electron or hadron transport without optical processes, add `--physics nonoptical` and
select `--particle e-`, `--particle proton`, `--particle pi+`, or `--particle neutron`. These runs use
identical LUND primary tracks across cases. Use `--events 10000 --transport-only` and a separate output
directory per particle. To compare STL loading alone, use `--cad-only-loading`; this artificial
configuration imports the meshes without the native detector hierarchy and runs no events.

Use a fresh output directory. On macOS, `/usr/bin/time -l` needs permission to read system resource statistics.
The output includes the exact gcard, mesh and executable hashes, per-run timing and warning counts, and raw logs.
Initialization, event transport, and overlap checking are measured separately. The full CAD implementation also
restores previously disabled walls and nose hardware, so its transport timings include those geometry changes.

Use `--restore-baseline-hardware` for the complete-hardware comparison: it enables all ten meshes
archived in the baseline's `cadTempRemoved/` directory and their legacy sector copies. This compares
18 original source meshes and 134,618 triangles against seven optimized meshes and 8,146 triangles
(93.9% fewer). Omitting this option compares the previously disabled production configuration against
the new complete implementation and changes the amount of simulated hardware.

In the October 2026 complete-hardware study, LTCC initialization used 63.5% less CPU time and 56.8%
less peak memory. Nonoptical electron transport had a 1.29-fold median throughput gain; hadrons used
1.35–1.53 times as much CPU time and optical electrons used 1.73 times as much. The optimized meshes
eliminated 1,714 invalid/rejected-facet warnings per import, and navigation warnings across the
tested workloads fell from 9,546 to one. The full implementation also changes materials and mothers,
so these results describe the complete model rather than an isolated mesh-navigation cost.
