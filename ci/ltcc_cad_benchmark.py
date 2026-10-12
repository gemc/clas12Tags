#!/usr/bin/env python3
"""Compare LTCC CAD data on macOS with one GEMC executable and an offline CCDB database."""

import argparse
import collections
import hashlib
import io
import json
import math
import os
from pathlib import Path
import re
import random
import shutil
import signal
import struct
import subprocess
import tarfile
import time
import xml.etree.ElementTree as ET


def mesh_inventory(folder):
    rows = []
    for volume in ET.parse(folder / "cad/cad_default.gxml").getroot():
        mesh = folder / "cad" / (volume.attrib["name"] + ".stl")
        data = mesh.read_bytes()
        triangles = struct.unpack_from("<I", data, 80)[0]
        if len(data) != 84 + 50 * triangles:
            raise ValueError("Expected a binary STL: " + str(mesh))
        rows.append({"name": mesh.stem, "bytes": len(data), "triangles": triangles,
                     "sha256": hashlib.sha256(data).hexdigest()})
    return rows


def fixed_primaries(particle, events, seed):
    """Use identical primary tracks across cases, independent of transport's random consumption."""
    pdg, charge, mass = {"e-": (11, -1, 0.000510999), "proton": (2212, 1, 0.938272),
                         "pi+": (211, 1, 0.139570), "neutron": (2112, 0, 0.939565)}[particle]
    rng = random.Random(seed)
    lines = []
    for _ in range(events):
        cosine = rng.uniform(math.cos(math.radians(35)), math.cos(math.radians(15)))
        phi = rng.uniform(-math.pi, math.pi)
        sine = math.sqrt(1 - cosine * cosine)
        px, py, pz = 5 * sine * math.cos(phi), 5 * sine * math.sin(phi), 5 * cosine
        lines.extend(["1 1 1 0 0 0 0 0 0 0",
                      f"1 {charge} 1 {pdg} 0 0 {px:.12g} {py:.12g} {pz:.12g} "
                      f"{math.sqrt(25 + mass * mass):.12g} {mass} 0 0 0"])
    return "\n".join(lines) + "\n"


def restore_baseline_hardware(repo, revision, folder):
    """Reactivate archived hardware using the placements/materials in the legacy frame script."""
    frame = [("S1-BW", 1), ("S1-LW", 4), ("S1-RW", 5), ("S1-TRB", 7)]
    nose = ["NFrame", "FrontPlate", "Mount", "Nose", "BottomPlate", "Epoxy"]
    path = folder / "cad/cad_default.gxml"
    root = ET.parse(path).getroot()
    for name in [name for name, _ in frame] + nose:
        original = f"geometry_source/ltcc/cadTempRemoved/{name}.stl"
        (folder / "cad" / (name + ".stl")).write_bytes(subprocess.check_output(
            ["git", "show", revision + ":" + original], cwd=repo))
        ET.SubElement(root, "volume", name=name, mother="root",
                      material="G4_CR39" if name == "Epoxy" else "G4_Al",
                      color="8888aa", position="0*mm 0*mm 1273.7*mm",
                      rotation="180*deg 0*deg " + ("60*deg" if name.startswith("S1-") else "120*deg"))
    ET.ElementTree(root).write(path)
    geometry = folder / "ltcc__geometry_default.txt"
    lines = geometry.read_text().splitlines()
    for sector in [1, 2, 4, 5, 6]:
        template = next(line.split("|") for line in lines if line.split("|")[0].strip() == f"frame2_s{sector}")
        parts = [(name, f"frame{number}_s{sector}", "G4_STAINLESS-STEEL", (sector - 2) * 60)
                 for name, number in frame]
        parts += [(name, f"nose{index + 1}_s{sector}", "G4_CR39" if name == "Epoxy" else "G4_Al",
                   (sector - 1) * 60) for index, name in enumerate(nose)]
        for source, name, material, angle in parts:
            row = template.copy()
            row[0], row[2], row[4] = name, f"Restored legacy LTCC hardware {name}", f"180*deg 0*deg {angle}*deg"
            row[6], row[8] = "CopyOf " + source, material
            lines.append(" | ".join(item.strip() for item in row))
    geometry.write_text("\n".join(lines) + "\n")


def run_case(executable, folder, logs, label, events, seed, overlaps, timeout, track_verbosity=0):
    name = f"{label}_n{events}_seed{seed}_overlaps{overlaps}"
    log = logs / (name + ".log")
    usage = logs / (name + ".time")
    cmd = [executable, "benchmark.gcard", "-USE_GUI=0", f"-N={events}",
           f"-RANDOM={seed}", f"-CHECK_OVERLAPS={overlaps}", "-GEO_VERBOSITY=0",
           f"-G4TRACK_VERBOSITY={track_verbosity}"]
    if events == 0:
        # GEMC treats N=0 with an input file as a request to process the complete file.
        cmd.append("-INPUT_GEN_FILE=gemc_internal")
    env = dict(os.environ, GEMC_DATA_DIR=str(folder))
    loader = ["/usr/bin/env", "DYLD_LIBRARY_PATH=" + env.get("DYLD_LIBRARY_PATH", "")]
    started = time.perf_counter()
    with log.open("w") as output:
        process = subprocess.Popen(["/usr/bin/time", "-l", "-o", str(usage), *loader, *cmd],
                                   cwd=folder, env=env, stdout=output, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        try:
            code = process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()
            code = "timeout"
    elapsed = time.perf_counter() - started
    content = log.read_text(errors="replace")
    codes = collections.Counter(re.findall(r"\*\*\* G4Exception : (\S+)", content))
    timing = re.search(r"Total gemc time: ([\d.e+-]+) seconds\.\s*Events only time: ([\d.e+-]+)",
                       content)
    memory = re.search(r"(\d+)\s+maximum resident set size", usage.read_text())
    result = {"case": label, "events": events, "seed": seed, "overlaps": overlaps,
              "exit_code": code, "wall_seconds": elapsed, "exception_codes": dict(codes),
              "warning_lines": len(re.findall(r"(?im)^.*\bwarning\b.*$", content)),
              "navigation_messages": len(re.findall(r"(?i)stuck track|track is stuck", content)),
              "completed": bool(timing), "command": cmd, "log": log.name,
              "rss_bytes": int(memory.group(1)) if memory else None}
    if track_verbosity:
        result["tracking_headers"] = len(re.findall(r"G4Track Information", content))
        result["step_rows"] = len(re.findall(r"(?m)^\s+\d+\s+[-\d.e+]+\s+[-\d.e+]+\s+[-\d.e+]+", content))
    if timing:
        result.update(total_cpu_seconds=float(timing.group(1)),
                      event_cpu_seconds=float(timing.group(2)))
    if (folder / "beam.lund").exists():
        result["primary_sha256"] = hashlib.sha256((folder / "beam.lund").read_bytes()).hexdigest()
    print(json.dumps(result), flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline-ref", required=True)
    parser.add_argument("--ccdb", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--events", type=int, default=1000)
    parser.add_argument("--repeats", type=int, default=5)
    parser.add_argument("--timeout", type=int, default=1800)
    parser.add_argument("--overlaps", action="store_true")
    parser.add_argument("--particle", choices=("e-", "proton", "pi+", "neutron"), default="e-")
    parser.add_argument("--physics", choices=("optical", "nonoptical"), default="optical")
    parser.add_argument("--transport-only", action="store_true", help="Skip repeated initialization runs")
    parser.add_argument("--fixed-primaries", action="store_true",
                        help="Use matched LUND tracks; always enabled for nonoptical runs")
    parser.add_argument("--cad-only-loading", action="store_true",
                        help="Load only STL solids with standard material and no detector hierarchy")
    parser.add_argument("--restore-baseline-hardware", action="store_true",
                        help="Enable all ten cadTempRemoved meshes and legacy sector copies in the baseline")
    parser.add_argument("--track-verbosity", type=int, choices=(0, 1, 2), default=0,
                        help="Diagnostic tracking output; do not use these runs for speed comparisons")
    args = parser.parse_args()
    args.fixed_primaries = args.fixed_primaries or args.physics == "nonoptical"
    if args.events <= 0 or args.repeats <= 0 or args.timeout <= 0:
        parser.error("Events, repeats, and timeout must be positive")
    repo = Path(__file__).resolve().parents[1]
    executable = shutil.which("gemc")
    if not executable or not args.ccdb.is_file():
        parser.error("Load a GEMC module and provide an existing local CCDB SQLite database")
    if args.output.exists():
        parser.error("Output directory already exists; use a new directory")
    args.output.mkdir(parents=True)
    os.environ["CCDB_CONNECTION"] = "sqlite:///" + str(args.ccdb.resolve()).lstrip("/")
    # macOS system Python and time discard DYLD variables at launch. Preserve the module's value
    # in LTCC_DYLD_LIBRARY_PATH before invoking Python, then restore it for the GEMC child.
    if "LTCC_DYLD_LIBRARY_PATH" in os.environ:
        os.environ["DYLD_LIBRARY_PATH"] = os.environ["LTCC_DYLD_LIBRARY_PATH"]
    relative = "experiments/clas12/ltcc"
    archive = tarfile.open(fileobj=io.BytesIO(subprocess.check_output(
        ["git", "archive", args.baseline_ref, relative], cwd=repo)))
    if any(Path(m.name).is_absolute() or ".." in Path(m.name).parts for m in archive.getmembers()):
        raise ValueError("Unsafe archive paths")
    archive.extractall(args.output / "old")
    old = args.output / "old" / relative
    new = args.output / "new" / relative
    cones = args.output / "cones_only" / relative
    if args.restore_baseline_hardware:
        restore_baseline_hardware(repo, args.baseline_ref, old)
    shutil.copytree(repo / relative, new)
    shutil.copytree(old, cones)
    for name in ("WC_S.stl", "WC_M.stl", "WC_L.stl"):
        shutil.copy2(new / "cad" / name, cones / "cad" / name)
    physics = "STD + FTFP_BERT" + (" + Optical" if args.physics == "optical" else "")
    card = f'''<gcard>
    <detector name="ltcc" factory="TEXT"/>
    <detector name="cad/" factory="CAD"/>
    <option name="RUNNO" value="11"/>
    <option name="BEAM_P" value="{args.particle}, 5.0*GeV, 25*deg, 0*deg"/>
    <option name="SPREAD_P" value="0*GeV, 10*deg, 180*deg"/>
    <option name="PHYSICS" value="{physics}"/>
    <option name="HALL_FIELD" value="no"/>
    <option name="OUTPUT" value="no, output"/>
</gcard>
'''
    cases = {"old": old, "cones_only": cones, "new": new}
    if args.cad_only_loading:
        card = card.replace('    <detector name="ltcc" factory="TEXT"/>\n', "")
        for folder in cases.values():
            path = folder / "cad/cad_default.gxml"
            root = ET.parse(path).getroot()
            for volume in root:
                volume.attrib = {"name": volume.attrib["name"], "mother": "root",
                                 "material": "G4_Al", "position": "0*mm 0*mm 0*mm",
                                 "rotation": "0*deg 0*deg 0*deg"}
            ET.ElementTree(root).write(path)
    if args.fixed_primaries:
        card = card.replace("</gcard>", '    <option name="INPUT_GEN_FILE" value="LUND, beam.lund"/>\n</gcard>')
    for folder in cases.values():
        (folder / "benchmark.gcard").write_text(card)
        if args.fixed_primaries:
            (folder / "beam.lund").write_text(fixed_primaries(args.particle, args.events, 12345))
    metadata = {"baseline_ref": args.baseline_ref, "executable": executable,
                "executable_sha256": hashlib.sha256(Path(executable).read_bytes()).hexdigest(),
                "ccdb": str(args.ccdb.resolve()), "card": card,
                "inventory": {label: mesh_inventory(folder) for label, folder in cases.items()},
                "version": subprocess.check_output([executable, "--version"], text=True),
                "platform": subprocess.check_output(["uname", "-a"], text=True)}
    metadata["arguments"] = vars(args).copy()
    metadata["arguments"]["ccdb"] = str(args.ccdb)
    metadata["arguments"]["output"] = str(args.output)
    metadata["data_sha256"] = {
        label: {str(path.relative_to(folder)): hashlib.sha256(path.read_bytes()).hexdigest()
                for path in sorted(folder.rglob("*")) if path.is_file()
                and path.suffix in (".txt", ".gxml", ".stl", ".gcard")}
        for label, folder in cases.items()}
    (args.output / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n")
    logs = args.output / "logs"
    logs.mkdir()
    results = []
    event_counts = [args.events] if args.transport_only else [0, args.events]
    if args.cad_only_loading:
        event_counts = [0]
    for events in event_counts:
        for repeat in range(args.repeats):
            order = list(cases)
            order = order[repeat % len(order):] + order[:repeat % len(order)]
            if args.fixed_primaries:
                primary = fixed_primaries(args.particle, args.events, 12345 + repeat)
                for folder in cases.values():
                    (folder / "beam.lund").write_text(primary)
            for label in order:
                results.append(run_case(executable, cases[label], logs, label, events,
                                        12345 + repeat, 0, args.timeout, args.track_verbosity))
                (args.output / "results.json").write_text(json.dumps(results, indent=2) + "\n")
    if args.overlaps:
        for label, folder in cases.items():
            results.append(run_case(executable, folder, logs, label, 0, 12345, 1, args.timeout))
            (args.output / "results.json").write_text(json.dumps(results, indent=2) + "\n")
    if any(r["exit_code"] != 0 or not r["completed"] for r in results):
        raise SystemExit("Some runs did not complete successfully; inspect results.json and the logs")


if __name__ == "__main__":
    main()
