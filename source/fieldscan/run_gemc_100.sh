#!/bin/zsh
# Verify the magnetic field gemc actually uses, by running gemc once per query point.
#
# Step 1: generate input.txt with the field-query points (100 random points,
#         seeded for reproducibility), in the form:
#             # x y z field-query points
#             0*cm, 0*cm, 0*cm
#             10*cm, 0*cm, 0*cm
#
# Step 2: read input.txt and, for each point, run gemc with that beam vertex and
#         FIELD_VERBOSITY=99. That prints the field at the first evaluation (the
#         vertex) and then suppresses further prints; we parse that line.
#
# Output: field_scan_gemc.txt, with aligned columns
#             x[cm] y[cm] z[cm] Bx[kG] By[kG] Bz[kG] |B|[kG]

set -e
cd "$(dirname "$0")"

# ---------------------------------------------------------------------------
# environment (same as the gemc/dev module)
# ---------------------------------------------------------------------------
source /opt/homebrew/opt/modules/init/zsh
module use /opt/projects/ceInstall/modules
module load gemc/dev
export FIELD_DIR=/opt/projects/ceInstall/noarch/data/magfield
export DYLD_LIBRARY_PATH="$LD_LIBRARY_PATH"   # macOS dyld uses DYLD_*, module sets LD_*

IN=input.txt
OUT=field_scan_gemc.txt
LOG=$(mktemp)

NPOINTS=100
SEED=12345

# ---------------------------------------------------------------------------
# Step 1: generate the query points (z in [-300,500] cm, radius in [0,500] cm,
# random azimuth) and write them in the requested "x*cm, y*cm, z*cm" format.
# ---------------------------------------------------------------------------
awk -v n=$NPOINTS -v seed=$SEED 'BEGIN{
    srand(seed);
    print "# x y z field-query points";
    for (i = 0; i < n; i++) {
        z   = -300.0 + 800.0 * rand();
        r   =    0.0 + 500.0 * rand();
        phi = 6.283185307179586 * rand();
        x = r * cos(phi);
        y = r * sin(phi);
        printf "%g*cm, %g*cm, %g*cm\n", x, y, z;
    }
}' > $IN

# ---------------------------------------------------------------------------
# Step 2: run gemc for every point and collect the field, in aligned columns.
# ---------------------------------------------------------------------------
{
  print "# CLAS12 composite field as evaluated by gemc (FIELD_VERBOSITY=99, B at beam vertex)"
  print "# torus & solenoid binary maps, both SCALE_FIELD=-1, no DISPLACE_FIELDMAP"
  printf "#%13s %14s %14s %14s %14s %14s %14s\n" \
         "x[cm]" "y[cm]" "z[cm]" "Bx[kG]" "By[kG]" "Bz[kG]" "|B|[kG]"
} > $OUT

n=0
# read input.txt, stripping "*cm" units and commas to get the three numbers
grep -v '^#' $IN | sed 's/\*cm//g; s/,/ /g' | while read x y z rest; do
    [[ -z "$x" ]] && continue
    n=$((n+1))
    gemc field_test.gcard -N=1 -USE_GUI=0 -BEAM_V="($x, $y, $z)cm" > $LOG 2>&1 || true

    # last "B = (bx, by, bz) gauss" line; convert gauss -> kG (/1000)
    line=$(grep "B = (" $LOG | tail -1)
    print -- "$line" | sed -E 's/.*\(([^)]*)\).*/\1/' | tr -d ' ' | \
    awk -F',' -v x=$x -v y=$y -v z=$z '{
        bx=$1/1000.0; by=$2/1000.0; bz=$3/1000.0;
        bmag=sqrt(bx*bx+by*by+bz*bz);
        printf "%14.3f %14.3f %14.3f %14.6g %14.6g %14.6g %14.6g\n", x,y,z,bx,by,bz,bmag;
    }' >> $OUT

    printf "\r  ran %3d/%d" $n $NPOINTS >&2
done
print "" >&2
rm -f $LOG
print "Wrote $IN ($NPOINTS points) and $OUT" >&2
