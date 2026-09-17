#!/usr/bin/env python3
"""Select nightly comparisons from commits in the last 24 hours.

Manual runs, unavailable history, and shared code changes use the full matrix.
"""

import json
import os
import re
import subprocess
from pathlib import Path


DETECTORS = [
    "ec", "pcal", "dc", "ftof", "ctof", "cnd", "bst", "htcc",
    "micromegas", "ltcc", "rich", "ft", "beamline", "magnets", "targets", "alert",
]
SHARED_FILES = {
    ".github/workflows/ascii_sqlite_comparison.yml",
    ".gitattributes",
    "create_geometry.sh",
    "clas12.sqlite",
    "ci/ascii_sqlite_matrix.py",
    "ci/build_gemc.sh",
    "ci/env.sh",
    "ci/install_comparison_software.sh",
    "ci/report_runs_and_variations.sh",
    "ci/txt_sql_geometry_comparison.sh",
    "ci/txt_sql_run_comparison.sh",
}


def select_detectors(paths):
    selected = set()
    for path in paths:
        if path in SHARED_FILES or path.startswith(("source/", "api/")):
            return DETECTORS.copy()
        match = re.match(r"^(?:geometry_source|experiments/clas12)/([^/]+)/", path)
        if match and match[1] in DETECTORS:
            selected.add(match[1])
        elif path.startswith(("geometry_source/", "experiments/clas12/")):
            # Shared helpers, Coatjava, or an unmapped geometry dependency: be conservative.
            return DETECTORS.copy()
    # The PCAL gcard loads EC; beamline loads FT. DC's extra beamline gcard is not
    # used by this comparison. Magnets only participates in the geometry matrix.
    if "ec" in selected:
        selected.add("pcal")
    if "ft" in selected:
        selected.add("beamline")
    return [detector for detector in DETECTORS if detector in selected]


def build_matrix(event_name, sha):
    selected = DETECTORS.copy()
    reason = "Full comparison requested manually."
    if event_name != "workflow_dispatch":
        try:
            # Include merge diffs and both sides of renames. Reading each commit also
            # catches files changed and subsequently reverted within the time window.
            result = subprocess.run(
                [
                    "git", "log", "--since=24 hours ago", "--format=", "--name-only",
                    "--no-renames", "-z", "-m", sha, "--",
                ],
                check=True, capture_output=True, text=True,
            )
            selected = select_detectors(filter(None, result.stdout.split("\0")))
            reason = "Files touched by commits in the last 24 hours."
        except (OSError, subprocess.CalledProcessError) as error:
            print(f"::warning::Cannot read recent commits: {error}")
            reason = "Commit history unavailable; running all detectors."

    run_detectors = [detector for detector in selected if detector != "magnets"]
    outputs = {
        "geometry": selected,
        "run": run_detectors,
        "has_geometry": bool(selected),
        "has_run": bool(run_detectors),
    }
    summary = (
        "### ASCII versus SQLite selection\n\n"
        f"{reason}\n\n"
        f"Geometry: {', '.join(selected) or 'none'}.\n\n"
        f"GEMC: {', '.join(run_detectors) or 'none'}.\n"
    )
    return outputs, summary


def main():
    outputs, summary = build_matrix(
        os.environ.get("GITHUB_EVENT_NAME", "schedule"), os.environ.get("GITHUB_SHA", "HEAD")
    )
    output_text = "".join(f"{key}={json.dumps(value)}\n" for key, value in outputs.items())
    if os.environ.get("GITHUB_OUTPUT"):
        with Path(os.environ["GITHUB_OUTPUT"]).open("a", encoding="utf-8") as output:
            output.write(output_text)
    else:
        print(output_text, end="")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with Path(os.environ["GITHUB_STEP_SUMMARY"]).open("a", encoding="utf-8") as output:
            output.write(summary)
    print(summary, end="")


if __name__ == "__main__":
    main()
