#!/usr/bin/env zsh

# Run wrapper for Callgrinder profiling: set up the GEMC2 module environment, then exec gemc.
# It runs NO valgrind and NO summary — the Callgrinder action wraps this in callgrind. `exec` makes
# callgrind profile gemc itself (the environment setup runs briefly in the pre-exec shell).
#
# Usage (as the Callgrinder `command`):  zsh ci/run_gemc.sh <gcard> <nevents>
# events.dat must already exist in the working directory (produced by the workflow's prepare step).

gcard="$1"
nevents="$2"

# ci/env.sh loads the gemc/dev, hipo, and ccdb modules and puts gemc on PATH.
source ci/env.sh

# Same options as on the OSG.
exec gemc \
	-INPUT_GEN_FILE="lund, events.dat" -USE_GUI=0 -N="$nevents" -PRINT_EVENT=10 -GEN_VERBOSITY=10 \
	-RANDOMIZE_LUND_VZ='-1.94*cm, 2.5*cm, reset ' \
	-BEAM_SPOT='0.0*mm, 0.0*mm, 0.0*mm, 0.0*mm, 0*deg, reset ' \
	-RASTER_VERTEX='0.0*cm, 0.0*cm, reset ' \
	-SCALE_FIELD='binary_torus, -1.00' -SCALE_FIELD='binary_solenoid, -1.00' \
	-INTEGRATEDRAW='*' "$gcard"
