#!/usr/bin/env bash
# Input is a CLAS12 calibration SQLite snapshot without the new test table.
# CCDB_USER must name a user in that snapshot. Only the private copy is written.
set -euo pipefail
src=$(cd "$(dirname "$0")/../.." && pwd)
parent=$(cd "${2:-${TMPDIR:-/tmp}}" && pwd)
out=$(mktemp -d "$parent/bmt-validation.XXXXXX")
echo "Validation output: $out"
cp "$1" "$out/test.sqlite"
export CCDB_CONNECTION="sqlite:///$out/test.sqlite"
table=/calibration/mvt/bmt_tile_efficiency
variation=rgd_fall2023_mc
fixture="$src/geometry_source/micromegas/ccdb/bmt_tile_efficiency_test.txt"
cd "$src/experiments/clas12/micromegas"
simulate() {
    local label=$1 run=$2 n=$3
    shift 3
    gemc micromegas_text_rgd_fall2023.gcard "-RUNNO=$run" "-DIGITIZATION_VARIATION=$variation" \
        -USE_GUI=0 -RANDOM=8241 "-N=$n" "-OUTPUT=hipo, $out/$label.hipo" "$@" >"$out/$label.log" 2>&1
}
reject() {
    local message=$1 label=$2
    shift 2
    if simulate "$label" "$@"; then echo "Expected startup failure for $label" >&2; exit 1; fi
    grep -F "bmt startup failed:" "$out/$label.log" | grep -F "$message"
    test ! -e "$out/$label.hipo"
    if grep -q 'Executing initial directives' "$out/$label.log"; then exit 1; fi
}
on=(-DETECTOR_INEFFICIENCY=1)
protons=('-BEAM_P=proton, 1*GeV, 70*deg, 90*deg' '-SPREAD_P=0.3*GeV, 15*deg, 15*deg')
probe=('-BEAM_P=chargedgeantino, 2*GeV, 80*deg, 90*deg' '-SPREAD_P=0*GeV, 0*deg, 0*deg' -RECORD_PASSBY=1)
# Run 10000 has nonzero drift HV and measured strip HV of zero on all 18 tiles.
simulate legacy-strip-off 10000 24 -DETECTOR_INEFFICIENCY=0 "${probe[@]}" -SKIPREJECTEDHITS=0
simulate measured-strip-off 10000 24 "${on[@]}" -BMT_ALLOW_MISSING_EFFICIENCY=1 "${probe[@]}" -SKIPREJECTEDHITS=0
reject "$table:18305:$variation" missing-table 18305 1 "${on[@]}"
ccdb --raise mktbl "$table" -r 18 sector=int layer=int component=int efficiency=double
ccdb --raise add "$table" -v "$variation" -r 18305-18305 "$fixture"
awk '!/^#/ && NF==4 {print $1,$2,$3,($1==1 && $2==5 ? 0 : 1)}' "$fixture" > "$out/unity.txt"
ccdb --raise add "$table" -v "$variation" -r 18306-18306 "$out/unity.txt"
printf '18305 1\n18307 0\n' > "$out/missing.weights"
reject "$table:18307:$variation" missing-assignment 18305 1 "${on[@]}" "-RUN_WEIGHTS=$out/missing.weights"
simulate fallback 18307 12 "${on[@]}" -BMT_ALLOW_MISSING_EFFICIENCY=1 -SKIPREJECTEDHITS=0 \
    '-BEAM_P=chargedgeantino, 2*GeV, 80*deg, 210*deg' '-SPREAD_P=0*GeV, 0*deg, 0*deg' -RECORD_PASSBY=1
grep -F 'bmt job summary:' "$out/fallback.log" | grep -F 'explicit unity fallback'
printf '18305 0.5\n18306 0.5\n' > "$out/switch.weights"
simulate switch 18305 120 "${on[@]}" "-RUN_WEIGHTS=$out/switch.weights" "${probe[@]}" -SKIPREJECTEDHITS=0
for run in 18305 18306; do
    request="$table:$run:$variation assignment "
    source_line=$(grep -F "bmt startup: $request" "$out/switch.log")
    grep -F "bmt job summary: ${source_line#*bmt startup: }" "$out/switch.log"
done
simulate unity-on 18306 300 "${on[@]}" "${protons[@]}" -SKIPREJECTEDHITS=0
simulate unity-off 18306 300 -DETECTOR_INEFFICIENCY=0 "${protons[@]}" -SKIPREJECTEDHITS=0
simulate full-truth 18305 1200 "${on[@]}" "${probe[@]}" -SKIPREJECTEDHITS=0
simulate kept-truth 18305 1200 "${on[@]}" "${probe[@]}" -SKIPREJECTEDHITS=1
grep -F 'SKIPREJECTEDHITS=1 drops fully rejected hits' "$out/kept-truth.log"
awk '!/^#/ && NF==4 {print $1,$2,$3,($1==1 && $2==5 ? 0.75 : $4)}' "$fixture" > "$out/invalid.txt"
ccdb --raise add "$table" -v "$variation" -r 18305-18305 "$out/invalid.txt"
reject 'sector 1 layer 5 has zero drift or strip voltage' inconsistent 18305 1 "${on[@]}" -BMT_ALLOW_MISSING_EFFICIENCY=1
# The July 2026 SQLite export has an empty HV type. Supply its numeric type for the CCDB CLI in our private copy.
sqlite3 "$out/test.sqlite" "UPDATE columns SET columnType='double' WHERE name='HV' AND columnType='' AND typeId IN (SELECT id FROM typeTables WHERE name='bmt_strip_voltage');"
awk '!/^#/ && NF==4 {print $1,$2,$3,($1==2 && $2==3 ? 0 : 500)}' "$fixture" > "$out/strip-off.txt"
ccdb --raise add /calibration/mvt/bmt_strip_voltage -v "$variation" -r 18306-18306 "$out/strip-off.txt"
reject 'sector 2 layer 3 has zero drift or strip voltage' strip-off 18306 1 "${on[@]}"
awk '!/^#/ && NF==4 {print ($1==3 && $2==6 ? 2 : $1),$2,$3,$4}' "$fixture" > "$out/duplicate.txt"
ccdb --raise add "$table" -v "$variation" -r 18305-18305 "$out/duplicate.txt"
reject "Duplicate BMT tile in $table:18305:$variation row 18 [2 6 0" duplicate 18305 1 "${on[@]}"
# Remove voltage sources from the private snapshot after the assignment/rate tests.
sqlite3 "$out/test.sqlite" "UPDATE typeTables SET name='test_hidden_strip_voltage' WHERE name='bmt_strip_voltage';"
reject "Missing BMT strip-voltage assignment" missing-strip 18307 1 "${on[@]}" -BMT_ALLOW_MISSING_EFFICIENCY=1
sqlite3 "$out/test.sqlite" "UPDATE typeTables SET name='test_hidden_drift_voltage' WHERE name='bmt_voltage';"
reject "Missing BMT drift-voltage assignment" missing-drift 18307 1 "${on[@]}" -BMT_ALLOW_MISSING_EFFICIENCY=1
simulate legacy-no-drift 18307 6 -DETECTOR_INEFFICIENCY=0 "${probe[@]}" -SKIPREJECTEDHITS=0
grep -F 'using zero drift voltage on all tiles' "$out/legacy-no-drift.log"
run-groovy "$src/ci/bmt_efficiency/check_banks.groovy" "$out"
