#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run --rm -it  ghcr.io/gemc/g4install:11.4.0-fedora-40  bash -li
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

source ci/env.sh

function show_gemc_installation {

	echo "- Content of \$GEMC=$GEMC" >>$gemc_install_show
	ls -lrt $GEMC >>$gemc_install_show

	echo "- Content of \$GEMC/bin=$GEMC/bin" >>$gemc_install_show
	ls -lrt $GEMC/bin >>$gemc_install_show

	if [ -d $GEMC/lib ]; then
		echo "- Content of \$GEMC/lib=$GEMC/lib" >>$gemc_install_show
		ls -lrt $GEMC/lib >>$gemc_install_show
	fi

	echo " ldd of $GEMC/bin/gemc:" >>$gemc_install_show

	# if on unix, use ldd , if on mac, use otool -L
	if [[ "$(uname)" == "Darwin" ]]; then
		otool -L $GEMC/bin/gemc >>$gemc_install_show
	else
		ldd $GEMC/bin/gemc >>$gemc_install_show
	fi

	echo " > To check gemc installation:  cat $gemc_install_show"

}

function compile_gemc {

	local install_dir="${GEMC:?GEMC not set}"
	local meson_option=(
		"--native-file=core.ini"
		"-Dprefix=${install_dir}"
		"-Dpkg_config_path=${PKG_CONFIG_PATH}:${install_dir}/lib/pkgconfig"
		"-Dbuildtype=release"
	)

	echo " > Geant-config: $(which geant4-config) : $(geant4-config --version)" | tee $setup_log
	echo
	echo " > Meson Setup Options: $meson_option"
	echo " > Using $jobs cores"
	echo

	cd source

	echo
	echo " > Running meson setup build $=meson_option" | tee -a $setup_log
	meson setup build $=meson_option >>$setup_log
	if [ $? -ne 0 ]; then
		echo " > Meson Configure failed. Log: "
		cat $setup_log
		exit 1
	else
		echo " > Meson Configure Successful"
		echo
	fi

	echo " > Running meson compile -C build -v -j $jobs " | tee -a $compile_log
	meson compile -C build -v -j $jobs >>$compile_log
	if [ $? -ne 0 ]; then
		echo " > Meson Compile failed. Log: "
		cat $compile_log
		exit 1
	else
		echo " > Meson Compile Successful"
		echo
	fi

	echo " > Running meson install -C build " | tee -a $install_log
	meson install -C build >>$install_log
	if [ $? -ne 0 ]; then
		echo " > Meson Install failed. Log: "
		cat $install_log
		exit 1
	else
		echo " > Meson Install Successful"
		echo
	fi

	show_gemc_installation
}

function create_geo_dbs {

	echo
	echo "Creating all geometry databases with: create_geometry.sh"
	echo START_CREATE_GEOMETRY $(date) | tee $geo_log
	./create_geometry.sh | tee -a $geo_log
	ls -lrt | tee -a $geo_log
	if [ $? -ne 0 ]; then
		echo "create_geometry failed. Log:"
		cat $geo_log
		exit 1
	fi

	echo
	echo "Changes after creation:"
	echo END_CREATE_GEOMETRY $(date) | tee -a $geo_log
	git branch
	git        status -s | tee -a $geo_log

	echo Final experiments/clas12 content | tee -a $geo_log
	ls -R experiments/clas12 | tee -a $geo_log

	echo "Copying experiments ASCII DB and sqlite file to $ARTIFACT_DIR for CI"
	cp -r experiments clas12.sqlite source/gemc_build.log geo_build.log geometry_source/build_coatjava.log $ARTIFACT_DIR
}

compile_gemc
create_geo_dbs

log_gemc_info
echo
echo "Content of $GEMC after geo creation:"
ls -lrt $GEMC
echo
echo "Content of artifacts dir $ARTIFACT_DIR:"
ls -lrt $ARTIFACT_DIR
echo
# copying executable, api and sqlite database for artifact retrieval
echo "Copying executable, experiments, api, sqlite database and mlibrary for artifact retrieval"
mkdir -p $ARTIFACT_DIR/bin
cp $GEMC/bin/gemc $ARTIFACT_DIR/bin
cp -r experiments $ARTIFACT_DIR
cp -r api $ARTIFACT_DIR
cp clas12.sqlite $ARTIFACT_DIR
