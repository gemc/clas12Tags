#!/bin/zsh
set -euo pipefail

# Purpose: Install gemc artifact in JLab's CVMFS

# -----------------------------
# Args / flags
# -----------------------------
dry_run=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    *) ;;
  esac
done

# -----------------------------
# Config
# -----------------------------
workdir=/work/clas12/ungaro/tmp
repo_url=https://github.com/gemc/clas12Tags.git
repo_name=clas12Tags
repo_subdir=experiments
get_artifact_py_rel=bin/get_last_ci_artifact.py

distros=(fedora almalinux)

typeset -A expdir
expdir[fedora]=/scigroup/cvmfs/geant4/fedora36-gcc12/clas12Tags/dev/experiments
expdir[almalinux]=/scigroup/cvmfs/geant4/almalinux9-gcc11/clas12Tags/dev/experiments

# -----------------------------
# Helpers
# -----------------------------
die() { print -u2 -- "ERROR: $*"; exit 1; }
ensure_dir() { mkdir -p -- "${1:?missing dir}"; }

run() {
  # Print the command always; execute only if not dry-run.
  if (( dry_run )); then
    print -- "[dry-run] $*"
  else
    eval "$@"
  fi
}

sync_repo() {
  local wd="${1:?missing workdir}"
  local url="${2:?missing repo url}"
  local name="${3:?missing repo name}"

  ensure_dir "$wd"
  cd "$wd"

  echo
  echo "Cloning or pulling ${name} repo"
  if [[ -d "$name/.git" ]]; then
    cd "$name"
    git pull
  else
    git clone "$url" "$name"
    cd "$name"
  fi
}

# Remove files under $target_dir that are NOT present in $repo_root/$repo_subdir
prune_not_in_repo() {
  local target_dir="${1:?missing target dir}"
  local repo_root="${2:?missing repo root}"
  local subdir="${3:?missing repo subdir}"

  [[ -d "$target_dir" ]] || die "Target dir not found: $target_dir"
  [[ -d "$repo_root/$subdir" ]] || die "Repo subdir not found: $repo_root/$subdir"

  echo "Removing files not present in ${target_dir}"

  find "$target_dir" -type f -print0 | while IFS= read -r -d '' file; do
    local rel="${file#$target_dir/}"
    if [[ ! -f "$repo_root/$subdir/$rel" ]]; then
      echo "Removing $file"
      run "rm -f -- ${(qq)file}"
    fi
  done
}

copy_repo_experiments() {
  local repo_root="${1:?missing repo root}"
  local subdir="${2:?missing repo subdir}"
  local target_dir="${3:?missing target dir}"

  echo "Copying ${subdir} files to ${target_dir}"
  # Use /. to copy contents, preserving structure
  run "cp -R -- ${(qq)repo_root}/$subdir/. ${(qq)target_dir}/"
}

fetch_last_ci_artifact_and_finalize() {
  local distro="${1:?missing distro}"
  local experiments_dir="${2:?missing experiments dir}"
  local repo_root="${3:?missing repo root}"
  local artifact_rel="${4:?missing artifact script rel path}"

  local parent="${experiments_dir:h}"    # zsh: parent dir
  local artifact_py="${repo_root}/${artifact_rel}"

  [[ -f "$artifact_py" ]] || die "Artifact script not found: $artifact_py"
  [[ -d "$parent" ]]      || die "Parent directory not found: $parent"

  echo
  echo "Getting last CI artifact in ${distro}"
  cd "$parent"
  echo "Current dir: $(pwd)"

  if (( dry_run )); then
    print -- "[dry-run] ${(qq)artifact_py} $distro"
    print -- "[dry-run] cp -R -- mlibrary/* ../../mlibrary/dev"
    print -- "[dry-run] rm -f -- gemc.zip"
  else
    "$artifact_py" "$distro"
    cp -R -- mlibrary/* ../../mlibrary/dev
    rm -f -- gemc.zip
  fi
}

# -----------------------------
# Main
# -----------------------------
if (( dry_run )); then
  echo "Running in --dry-run mode: no changes will be made."
fi

ensure_dir "$workdir"
sync_repo "$workdir" "$repo_url" "$repo_name"
repo_root="$(pwd)"  # now inside repo after sync_repo

for d in "${distros[@]}"; do
  [[ -n "${expdir[$d]:-}" ]] || die "No expdir mapping for distro '$d'"
done

for d in "${distros[@]}"; do
  prune_not_in_repo "${expdir[$d]}" "$repo_root" "$repo_subdir"
done

echo
echo "Copying experiments files to all distros: ${distros[*]}"
for d in "${distros[@]}"; do
  copy_repo_experiments "$repo_root" "$repo_subdir" "${expdir[$d]}"
done

for d in "${distros[@]}"; do
  fetch_last_ci_artifact_and_finalize "$d" "${expdir[$d]}" "$repo_root" "$get_artifact_py_rel"
done

echo
echo "Done!"
