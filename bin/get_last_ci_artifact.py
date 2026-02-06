#!/usr/bin/env python3
import argparse
import os
import sys
import zipfile
import io
import requests
import subprocess
import tempfile


def die(msg, code=1):
	print(msg, file=sys.stderr)
	sys.exit(code)


def read_token():
	path = os.path.expanduser("~/.mauri")
	if not os.path.exists(path):
		die(f"Token file not found: {path}\nCreate it with your GitHub PAT (classic).")
	with open(path, "r") as f:
		token = f.read().strip()
	if not token:
		die(f"Token file {path} is empty.")
	return token


def pick_workflow(os_type: str) -> str:
	mapping = {
		"almalinux": "build_gemc_almalinux.yml",
		"fedora":    "build_gemc_fedora.yml",
		"ubuntu":    "build_gemc_ubuntu.yml",
	}
	return mapping[os_type]


def gh_get(url: str, token: str, params=None):
	headers = {
		"Authorization": f"Bearer {token}",
		"Accept":        "application/vnd.github+json",
		"User-Agent":    "gemc-ci-fetcher",
	}

	r = requests.get(url, headers=headers, params=params, timeout=60)
	# Surface helpful details on 401
	# Surface helpful details on 401
	if r.status_code == 401:
		tok_len = len(token)
		tok_prefix = token[:10] + "…" if tok_len >= 10 else token
		die(
			"Failed to authenticate with GitHub (401 Bad credentials).\n"
			"- The token may be expired, revoked, or not the one you intended (\"not renewed\").\n"
			"- Confirm the token file (~/.mauri) contains the correct current token.\n"
			f"- Token fingerprint (safe): prefix={tok_prefix}  length={tok_len}\n"
			"- If you are using a classic PAT, 'Authorization: token <PAT>' should work.\n"
			"- If you are using a fine-grained PAT, ensure the repository is allowed and\n"
			"  the required permissions (e.g., Actions: Read) are enabled.\n"
			f"Response: {r.text}"
		)

	r.raise_for_status()
	return r


def download_artifact_zip(download_url: str, token: str, artifact_name: str):
	session = requests.Session()

	api_headers = {
		"Authorization":        f"Bearer {token}",
		"Accept":               "application/vnd.github+json",
		"X-GitHub-Api-Version": "2022-11-28",
		"User-Agent":           "gemc-ci-fetcher",
	}

	# 1) Ask GitHub API for the redirect target (no auto-redirect)
	r = session.get(download_url, headers=api_headers, allow_redirects=False, timeout=(30, 60))
	if r.status_code == 401:
		die("401 downloading artifact redirect: token may be expired/revoked/not renewed.\n"
		    f"Response: {r.text}")
	r.raise_for_status()

	if r.status_code not in (301, 302, 307, 308) or "Location" not in r.headers:
		die(f"Expected redirect for artifact download, got HTTP {r.status_code}.\nResponse: {r.text}")

	direct_url = r.headers["Location"]
	print(f"Redirected to: {direct_url}")
	host = direct_url.split("/")[2]
	print(f"NOTE: redirected host is {host}. If downloads fail with connection resets, "
	      f"this host may be blocked from this network; try proxy or download elsewhere.")

	# 2) Download via curl (works in your environment), then unzip
	with tempfile.NamedTemporaryFile(prefix=f"{artifact_name}_", suffix=".zip", delete=False) as tf:
		zip_path = tf.name

	cmd = [
		"curl",
		"-L", "--fail",
		"--retry", "2",  "--retry-delay", "1",
		"--connect-timeout", "20", "--max-time", "600",
		"-o", zip_path,
		direct_url,
	]

	try:
		subprocess.run(cmd, check=True)
	except subprocess.CalledProcessError as e:
		die(f"curl failed while downloading artifact zip.\nCommand: {' '.join(cmd)}\nError: {e}")

	with zipfile.ZipFile(zip_path) as zf:
		zf.extractall(".")
	os.unlink(zip_path)

	print(f"Artifact '{artifact_name}' downloaded and extracted.")


def main():
	parser = argparse.ArgumentParser(
		description="Fetch latest artifact from a workflow on main for a given OS."
	)
	parser.add_argument("os_type", choices=["almalinux", "fedora", "ubuntu"],
	                    help="Which OS workflow to use.")
	args = parser.parse_args()

	token = read_token()
	repo = "gemc/clas12Tags"
	workflow_id = pick_workflow(args.os_type)

	# 1) List runs for that workflow
	runs_url = f"https://api.github.com/repos/{repo}/actions/workflows/{workflow_id}/runs"
	runs = gh_get(runs_url, token, params={"per_page": 50}).json().get("workflow_runs", [])

	# Filter to main branch and prefer the most recent successful run (if available)
	main_runs = [run for run in runs if run.get("head_branch") == "main"]
	if not main_runs:
		die("No workflow runs found for 'main' branch.")

	# Prefer completed+successful; otherwise fall back to the newest main run
	successful = [r for r in main_runs if
	              r.get("status") == "completed" and r.get("conclusion") == "success"]
	chosen = successful[0] if successful else main_runs[0]
	run_id = chosen["id"]
	run_html = chosen.get("html_url", "(no url)")
	print(
		f"Using run {run_id} {run_html} (status={chosen.get('status')}, conclusion={chosen.get('conclusion')})")

	# 2) Get artifacts for that run
	arts_url = f"https://api.github.com/repos/{repo}/actions/runs/{run_id}/artifacts"
	artifacts = gh_get(arts_url, token).json().get("artifacts", [])

	if not artifacts:
		die(f"No artifacts found for run id {run_id} on 'main'.")

	# Pick the newest artifact (GitHub returns newest first)
	latest = artifacts[0]
	name = latest["name"]
	dl_url = latest["archive_download_url"]
	print(f"Latest artifact: {name}\nDownload URL: {dl_url}")

	download_artifact_zip(dl_url, token, name)


if __name__ == "__main__":
	main()
