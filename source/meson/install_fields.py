#!/usr/bin/env python3
# Installs the CLAS12 magnetic field maps into $MESON_INSTALL_PREFIX/fields.
#
# The maps come from the magfield git-lfs subproject (source/subprojects/magfield), whose path is
# passed as argv[1] by source/meson/meson.build. Every *.dat file in that directory is copied,
# unless an up-to-date copy of the same size already exists (idempotent). Missing maps and
# unresolved git-lfs pointer files are hard errors: rerun after `git lfs install && git lfs pull`
# in the subproject.

import os
import shutil
import sys
from pathlib import Path

# All git-lfs pointer files begin with this spec line, regardless of the hosting server.
LFS_POINTER_PREFIX = b'version https://git-lfs.github.com/spec/'


def is_lfs_pointer(path: Path) -> bool:
    try:
        with open(path, 'rb') as fh:
            return fh.read(len(LFS_POINTER_PREFIX)) == LFS_POINTER_PREFIX
    except OSError:
        return False


def main() -> int:
    if len(sys.argv) < 2:
        print('  ERROR: magfield source directory not provided', file=sys.stderr)
        return 1

    source_dir = Path(sys.argv[1])
    field_dir = Path(os.environ['MESON_INSTALL_PREFIX']) / 'fields'
    field_dir.mkdir(parents=True, exist_ok=True)
    print(f'Field maps: {source_dir} -> {field_dir}')

    maps = sorted(source_dir.glob('*.dat'))
    if not maps:
        print(f'  ERROR: no field maps (*.dat) found in {source_dir}', file=sys.stderr)
        return 1

    pointers = [m.name for m in maps if is_lfs_pointer(m)]
    if pointers:
        print(
            '  ERROR: git-lfs content not resolved for: ' + ', '.join(pointers),
            file=sys.stderr,
        )
        print(
            f'         run: git -C {source_dir} lfs install && git -C {source_dir} lfs pull',
            file=sys.stderr,
        )
        return 1

    for src in maps:
        dst = field_dir / src.name
        if dst.exists() and dst.stat().st_size == src.stat().st_size:
            print(f'  ok (cached) {src.name}')
            continue
        shutil.copy2(src, dst)
        print(f'  installed {src.name}')

    print('Field maps done.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
