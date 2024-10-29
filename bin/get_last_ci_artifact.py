#!/opt/homebrew/Cellar/python@3.11/3.11.10/bin/python3.11

import requests
import subprocess
import os

# add function to download artifact using curl
def download_artifact(download_url, token, artifact_name):
	filename = f"{artifact_name}.zip"
	curl_accept1 = "Accept: application/vnd.github+json"
	curl_accept2 = "Authorization: token " + token
	curl_command = f"curl  -H '{curl_accept1}' -H '{curl_accept2}' -L -o {filename} {download_url}"
	# exectute the curl command
	result = subprocess.run(curl_command, shell=True, capture_output=True, text=True)
	# unzip the resulting artifact
	if result.returncode == 0:
		print(f"Artifact {artifact_name} downloaded successfully.")
		# Unzip the artifact if it's a zip file
		if filename.endswith('.zip'):
			unzip_command = f"unzip {filename}"
			subprocess.run(unzip_command, shell=True)
	else:
		print(f"Failed to download artifact: {result.stderr}")

# Define the variables
# Use HOME environment variable to get the path
with open(f"{os.path.expanduser('~')}/.mauri") as f:
	MAURI = f.read().strip()

REPO = "gemc/clas12Tags"  # e.g., "octocat/Hello-World"
WORKFLOW_ID = "build_gemc.yml"  # e.g., "build.yml" or the workflow ID number

# Set up the headers for authentication
headers = {
	"Authorization": f"Bearer {MAURI}",
	"Accept":        "application/vnd.github.v3+json"
}

# Step 1: Get the latest runs for the specified workflow
runs_url = f"https://api.github.com/repos/{REPO}/actions/workflows/{WORKFLOW_ID}/runs"
runs_response = requests.get(runs_url, headers=headers)

if runs_response.status_code == 200:
	runs = runs_response.json().get("workflow_runs", [])

	if runs:
		# Get the latest run
		latest_run_id = runs[0]["id"]

		# Step 2: Get artifacts for the latest run
		artifacts_url = f"https://api.github.com/repos/{REPO}/actions/runs/{latest_run_id}/artifacts"
		artifacts_response = requests.get(artifacts_url, headers=headers)


		if artifacts_response.status_code == 200:
			artifacts = artifacts_response.json().get("artifacts", [])

			if artifacts:
				# Get the latest artifact
				latest_artifact = artifacts[0]
				print("Latest Artifact Name:", latest_artifact["name"])
				print("Download URL:", latest_artifact["archive_download_url"])

				# download the latest artifact
				download_artifact(latest_artifact["archive_download_url"], MAURI, latest_artifact["name"])


			else:
				print("No artifacts found for the latest workflow run.")
		else:
			print("Failed to get artifacts:", artifacts_response.status_code,
			      artifacts_response.text)
	else:
		print("No workflow runs found.")
else:
	print("Failed to get workflow runs:", runs_response.status_code, runs_response.text)
