#!/usr/bin/env python3
"""
randomize_angles.py  –  rotate particle momenta and replicate events.

Examples
--------
# make 100 events from "in.dat", reproducible with seed 42
python randomize_angles.py in.dat --nevents 100 --seed 42 -o out.dat
"""
import argparse, math, random, sys
from typing import List, TextIO, Tuple


# ---------------------------------------------------------------------------
# utilities
# ---------------------------------------------------------------------------

def random_direction(p: float,
                     theta_min_deg: float,
                     theta_max_deg: float) -> Tuple[float, float, float]:
    """Return a new (px,py,pz) with magnitude *p* and random direction."""
    phi   = math.radians(random.uniform(0.0, 360.0))
    theta = math.radians(random.uniform(theta_min_deg, theta_max_deg))
    px = p * math.sin(theta) * math.cos(phi)
    py = p * math.sin(theta) * math.sin(phi)
    pz = p * math.cos(theta)
    return px, py, pz


# ---------------------------------------------------------------------------
# event handling
# ---------------------------------------------------------------------------

def read_events(fin: TextIO) -> List[List[str]]:
    """
    Read the whole file, returning a list of events,
    each event being a list[str] (header first, then particles).
    """
    events: List[List[str]] = []
    while True:
        header = fin.readline()
        if not header:                # EOF
            break
        if not header.strip():        # skip blank lines
            continue

        tokens = header.split()
        try:
            n_particles = int(float(tokens[0]))
        except ValueError:
            # not an event header → copy verbatim as a 1‑line “event”
            events.append([header.rstrip("\n")])
            continue

        # collect the event
        evt_lines = [header.rstrip("\n")]
        for _ in range(n_particles):
            line = fin.readline()
            if not line:
                raise RuntimeError("Unexpected EOF inside event")
            evt_lines.append(line.rstrip("\n"))
        events.append(evt_lines)
    return events


def rotate_event(evt: List[str],
                 theta_min: float,
                 theta_max: float) -> List[str]:
    """
    Return a **new** list[str] with momenta randomized.
    evt[0] is the header, evt[1:] are particle lines.
    """
    if len(evt) == 1:
        # single‑line “event” (comment etc.) – just copy
        return evt.copy()

    header = evt[0]
    rotated = [header]

    for line in evt[1:]:
        tokens = line.split()
        if len(tokens) < 9:
            rotated.append(line)          # malformed → pass through
            continue

        px, py, pz = map(float, tokens[6:9])
        p = math.sqrt(px*px + py*py + pz*pz)
        new_px, new_py, new_pz = random_direction(p, theta_min, theta_max)
        tokens[6] = f"{new_px:.6f}"
        tokens[7] = f"{new_py:.6f}"
        tokens[8] = f"{new_pz:.6f}"
        rotated.append(" ".join(tokens))

    return rotated


def emit_events(events: List[List[str]],
                nevents: int,
                fout: TextIO,
                theta_min: float,
                theta_max: float):
    """
    Write *nevents* events to *fout*, cycling through *events* list
    and randomizing the angles every time.
    """
    total_input = len(events)
    if total_input == 0:
        raise RuntimeError("Input contained no events")

    for i in range(nevents):
        evt = events[i % total_input]
        for line in rotate_event(evt, theta_min, theta_max):
            print(line, file=fout)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    ap = argparse.ArgumentParser(
        description=("Randomize φ (0–360°) and θ (default 7–120°) of every "
                     "particle momentum vector and replicate events until "
                     "the desired total is reached."))
    ap.add_argument("input",
                    help="input file ('-' for stdin)")
    ap.add_argument("--nevents", type=int, required=True,
                    help="total number of events in the output")
    ap.add_argument("-o", "--output",
                    help="output file (default: stdout)")
    ap.add_argument("--theta-min", type=float, default=7.0,
                    help="minimum θ in degrees (default 7)")
    ap.add_argument("--theta-max", type=float, default=120.0,
                    help="maximum θ in degrees (default 120)")
    ap.add_argument("--seed", type=int,
                    help="set RNG seed for reproducibility")

    args = ap.parse_args()

    # reproducibility?
    if args.seed is not None:
        random.seed(args.seed)

    fin  = sys.stdin  if args.input  == "-" else open(args.input,  "r")
    fout = sys.stdout if args.output is None else open(args.output, "w")

    try:
        events = read_events(fin)
        emit_events(events, args.nevents, fout,
                    args.theta_min, args.theta_max)
    finally:
        if fin  is not sys.stdin:  fin.close()
        if fout is not sys.stdout: fout.close()


if __name__ == "__main__":
    main()
