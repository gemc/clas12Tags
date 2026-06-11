#!/usr/bin/env python3
# Downloads CLAS12 magnetic field maps into $MESON_INSTALL_PREFIX/fields.
# Each file is skipped when it already exists (idempotent).
# Download order: wget → curl → urllib (server blocks Python-urllib UA).

import os
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

field_dir = Path(os.environ['MESON_INSTALL_PREFIX']) / 'fields'
field_dir.mkdir(parents=True, exist_ok=True)
print(f'Field maps → {field_dir}')

BINARY_BASE = 'https://clasweb.jlab.org/clas12offline/magfield'
ASCII_BASE   = 'https://clasweb.jlab.org/12gev/field_maps'

binary_maps = [
    'Symm_solenoid_r601_phi1_z1201_13June2018',
    'Symm_torus_r2501_phi16_z251_24Apr2018',
    'Full_torus_r251_phi181_z251_25Jan2021',
    'Full_torus_r251_phi181_z251_03March2020',
    'Full_torus_r251_phi181_z251_08May2018',
    'Full_transsolenoid_x321_y161_z321_March2021_April2024',
]
ascii_maps = ['TorusSymmetric', 'clas12NewSolenoidFieldMap']


def fetch(url: str, dest: Path) -> bool:
    print(f'  downloading {url}')
    for cmd in (
        ['wget', '-q', '-O', str(dest), url],
        ['curl', '-fsSL', '-o', str(dest), url],
    ):
        if shutil.which(cmd[0]) is None:
            continue
        result = subprocess.run(cmd, capture_output=True)
        if result.returncode == 0 and dest.exists() and dest.stat().st_size > 0:
            return True
        dest.unlink(missing_ok=True)

    # Last-resort: urllib with a wget-like User-Agent
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Wget/1.21.1'})
        with urllib.request.urlopen(req) as resp, open(dest, 'wb') as fh:
            fh.write(resp.read())
        return True
    except Exception as exc:
        print(f'  WARNING: could not download {url}: {exc}', file=sys.stderr)
        dest.unlink(missing_ok=True)
        return False


for name in binary_maps:
    dest = field_dir / f'{name}.dat'
    if dest.exists():
        print(f'  ok (cached) {name}.dat')
    else:
        fetch(f'{BINARY_BASE}/{name}.dat', dest)

# April2024 is an alias for the March2021_April2024 map
src = field_dir / 'Full_transsolenoid_x321_y161_z321_March2021_April2024.dat'
dst = field_dir / 'Full_transsolenoid_x321_y161_z321_April2024.dat'
if src.exists() and not dst.exists():
    shutil.copy2(src, dst)
    print('  created Full_transsolenoid_x321_y161_z321_April2024.dat')

for name in ascii_maps:
    dest = field_dir / f'{name}.dat'
    if dest.exists():
        print(f'  ok (cached) {name}.dat')
    else:
        fetch(f'{ASCII_BASE}/{name}.dat', dest)

print('Field maps done.')
