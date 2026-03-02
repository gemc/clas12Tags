#!/usr/bin/env bash
set -euo pipefail

log_file="${1:-/root/logs/eff.log}"

if [[ ! -f "$log_file" ]]; then
  echo "eff_summary.sh: missing log file: $log_file" >&2
  exit 0
fi

# Generate markdown to stdout
md="$(
python3 - "$log_file" <<'PY'
import json, sys

log_file = sys.argv[1]

last = None
with open(log_file, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        s = line.strip()
        if s.startswith("{") and s.endswith("}"):
            last = s

if not last:
    print(f"No JSON line found in {log_file}", file=sys.stderr)
    sys.exit(0)

data = json.loads(last)
pids = [str(x) for x in data["pids"]]
effs = data["effs"]
gens = data["gens"]

out = []
out.append("## Efficiencies")
out.append("")
out.append(f"Source: `{log_file}`")
out.append("")
out.append("| pid  | " + " | ".join(pids) + " |")
out.append("|---" + "|---"*len(pids) + "|")

for rpid in pids:
    if int(gens.get(rpid, 0)) == 0:
        row = [rpid] + ["-"] * len(pids)
    else:
        vals = effs.get(rpid, [0.0] * len(pids))
        if len(vals) < len(pids):
            vals = vals + [0.0] * (len(pids) - len(vals))
        elif len(vals) > len(pids):
            vals = vals[:len(pids)]
        row = [rpid] + [f"{v:.4f}" for v in vals]
    out.append("| " + " | ".join(row) + " |")

out.append("")
print("\n".join(out))
PY
)"

# Append to GitHub job summary when available
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '%s\n' "$md" >> "$GITHUB_STEP_SUMMARY"
else
  printf '%s\n' "$md"
fi