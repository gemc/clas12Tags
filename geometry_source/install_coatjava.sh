#!/bin/zsh

function mwget() {
	# Linux: -c = do not get file if already done.
	if [[ $(uname) == "Linux" ]]; then
		wget -c -nv --no-check-certificate $@
	# Mac: makes it quiet and shows nice progress
	elif [[ $(uname) == "Darwin" ]]; then
		wget -qc --show-progress --no-check-certificate $@
	fi

}

log_file="$PWD/build_coatjava.log"
echo START_INSTALL_COATJAVA $(date) > "$log_file"

if [[ ${GITHUB_ACTIONS:-} == true ]]; then
	bash ../ci/configure_java_trust.sh || exit 1
fi

rm -rf coat*jar jcsg*jar vecmath*jar

# development. Set to no to use coatjava distribution instead
USEDEVEL="no"
githubRepo="https://github.com/JeffersonLab/coatjava"

REPO="JeffersonLab/coatjava"
# wait a bit before retrying to avoid rate limiting
while [[ "$LATEST_RELEASE" == "null" || -z "$LATEST_RELEASE" ]]; do
  echo "Fetching latest release from $REPO..."
  LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)

  [[ -z "$LATEST_RELEASE" ]] && sleep 2
done

echo "Latest coatjava release from $REPO: $LATEST_RELEASE"

# if the -g option is given, set the github url accordingly
# if the -t option is given, set the coatjava tag accordingly
if [[ $1 == "-g" ]]; then
	githubRepo=$2
	USEDEVEL="yes"
	echo "Requested Coatjava Repository: $githubRepo"
elif [[ $1 == "-t" ]]; then
	COATJAVA_TAG=$2
	USEDEVEL="no"
	tag_gz="$githubRepo/archive/refs/tags/$COATJAVA_TAG"".tar.gz"
	echo "Requested Coatjava Tag: $COATJAVA_TAG"
elif [[ $1 == "-l" ]]; then
	COATJAVA_TAG=$LATEST_RELEASE
	USEDEVEL="no"
	tag_gz="$githubRepo/archive/refs/tags/$COATJAVA_TAG"".tar.gz"
	echo "Requested Latest Coatjava Release: $LATEST_RELEASE"
fi

# print help if -h is given
if [[ $1 == "-h" ]]; then
	echo "Usage: install_coatjava.sh [-d] [-t tag]"
	echo "  -d: use coatjava development version (github main)"
	echo "  -t tag: use coatjava tag version"
	echo "  -g github_url: use a custom github url"
	echo "  -l use latest tag"
	exit 0
fi

install_dir=coatjava
src_dir=coatjava_src

rm -rf $install_dir $src_dir

if [[ $USEDEVEL == "yes" ]]; then
	echo
	echo "Cloning $githubRepo and building coatjava"
	echo
	git clone $githubRepo $src_dir || exit 1
else
	git clone -b $COATJAVA_TAG --depth 1 $githubRepo $src_dir || exit 1
fi

# recent versions of Git refuse to touch a repository whose on-disk owner
# doesn’t match the UID that is running the command
# mark the workspace (and any nested path) as safe
echo "Marking workspace as safe for Git"
git config --global --add safe.directory '*'

cd $src_dir || exit 1
# Limit dependency downloads as well as reactor threads, as in Coatjava's CI.
maven_options=(--batch-mode -T1 -Dmaven.artifact.threads=1 -Daether.connector.http.retryHandler.count=5)
echo "Running coatjava build with options: --lfs --no-progress --nomaps $maven_options" | tee -a "$log_file"
./build-coatjava.sh --lfs --no-progress --nomaps "${maven_options[@]}" &>> "$log_file"
if [[ $? -ne 0 ]]; then
	echo "Error: coatjava build failed. Log:"
	cat "$log_file"
	exit 1
fi
cp coatjava/lib/clas/* .. || exit 1
cp -r coatjava ../$install_dir || exit 1
echo END_INSTALL_COATJAVA $(date) >> "$log_file"
