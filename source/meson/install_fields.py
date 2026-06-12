#!/usr/bin/env python3
# Downloads CLAS12 magnetic field maps into $MESON_INSTALL_PREFIX/fields.
# Each file is skipped when it already exists (idempotent).
# Download order: wget -> curl -> urllib (server blocks Python-urllib UA).

import os
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

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


def required() -> bool:
    return os.environ.get('GEMC_INSTALL_FIELDS_REQUIRED') == '1'


def warn(message: str) -> None:
    print(f'  WARNING: {message}', file=sys.stderr)


def fetch(url: str, dest: Path) -> bool:
    print(f'  downloading {url}')
    for cmd in (
        ['wget', '-q', '-O', str(dest), url],
        ['curl', '-fsSL', '-o', str(dest), url],
    ):
        if shutil.which(cmd[0]) is None:
            continue
        try:
            result = subprocess.run(cmd, capture_output=True)
        except OSError as exc:
            warn(f'could not run {cmd[0]}: {exc}')
            continue
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
        warn(f'could not download {url}: {exc}')
        dest.unlink(missing_ok=True)
        return False


def fetch_map(base_url: str, field_dir: Path, name: str) -> bool:
    dest = field_dir / f'{name}.dat'
    if dest.exists():
        print(f'  ok (cached) {name}.dat')
        return True
    return fetch(f'{base_url}/{name}.dat', dest)


def main() -> int:
    field_dir = Path(os.environ['MESON_INSTALL_PREFIX']) / 'fields'
    field_dir.mkdir(parents=True, exist_ok=True)
    print(f'Field maps -> {field_dir}')

    failures = []
    for name in binary_maps:
        if not fetch_map(BINARY_BASE, field_dir, name):
            failures.append(name)

    src = field_dir / 'Full_transsolenoid_x321_y161_z321_March2021_April2024.dat'
    dst = field_dir / 'Full_transsolenoid_x321_y161_z321_April2024.dat'
    if src.exists() and not dst.exists():
        shutil.copy2(src, dst)
        print('  created Full_transsolenoid_x321_y161_z321_April2024.dat')

    for name in ascii_maps:
        if not fetch_map(ASCII_BASE, field_dir, name):
            failures.append(name)

    if failures:
        warn('missing field maps: ' + ', '.join(failures))
        if required():
            return 1
        warn('continuing; set GEMC_INSTALL_FIELDS_REQUIRED=1 to make this fatal')

    print('Field maps done.')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        warn(f'field-map install skipped after unexpected error: {exc}')
        sys.exit(1 if required() else 0)
