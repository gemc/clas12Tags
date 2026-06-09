#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run --rm -it  ghcr.io/gemc/g4install:11.4.0-fedora-40  bash -li
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

source ci/env.sh

function show_gemc_installation {

	echo "- Content of \$GEMC=$GEMC" | tee $gemc_install_show
	ls -lrt $GEMC | tee -a $gemc_install_show

	echo "- Content of \$GEMC/bin=$GEMC/bin" | tee -a $gemc_install_show
	ls -lrt $GEMC/bin | tee -a $gemc_install_show

	echo "- Content of \$GEMC_DATA_DIR=$GEMC_DATA_DIR" | tee -a $gemc_install_show
	ls -lrt $GEMC_DATA_DIR | tee -a $gemc_install_show

	if [ -d $GEMC/lib ]; then
		echo "- Content of \$GEMC/lib=$GEMC/lib" | tee -a $gemc_install_show
		ls -lrt $GEMC/lib | tee -a $gemc_install_show
	fi

	# if on unix, use ldd , if on mac, use otool -L
	if [[ "$(uname)" == "Darwin" ]]; then
		otool -L $GEMC/bin/gemc | tee -a $gemc_install_show
	else
		ldd $GEMC/bin/gemc | tee -a $gemc_install_show
	fi
	echo
	echo "Instrospection: Running GEMC" | tee -a $gemc_install_show
	echo $(gemc --version) | tee -a $gemc_install_show

	echo "  To check gemc installation:  cat $gemc_install_show"

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
	cd ..

	# installing api into $GEMC
	cp -r api $GEMC
}

function create_geo_dbs {

	echo
	echo "Creating all geometry databases with: create_geometry.sh"
	echo START_CREATE_GEOMETRY $(date) | tee $geo_log
	./create_geometry.sh | tee -a $geo_log
	if [ $? -ne 0 ]; then
		echo "create_geometry failed. Log:"
		cat $geo_log
		exit 1
	fi
	ls -lrt | tee -a $geo_log

	echo
	echo "Changes after creation:"
	echo END_CREATE_GEOMETRY $(date) | tee -a $geo_log
	git branch
	git status -s | tee -a $geo_log

	echo Final experiments/clas12 content | tee -a $geo_log
	ls -R experiments/clas12 | tee -a $geo_log

	echo "Copying experiments ASCII DB and sqlite file to $ARTIFACT_DIR for CI"
	cp -r experiments clas12.sqlite source/gemc_build.log geo_build.log geometry_source/build_coatjava.log $ARTIFACT_DIR
}

compile_gemc

# log info
show_gemc_installation
log_java_info

# create geometry
create_geo_dbs

# install magnetic fields
ci/install_fields.zsh


echo
echo "Copying executable, experiments, api, sqlite database for artifact retrieval"
mkdir -p $ARTIFACT_DIR/bin
cp $GEMC/bin/gemc $ARTIFACT_DIR/bin
cp -r experiments $ARTIFACT_DIR
cp -r api $ARTIFACT_DIR
cp clas12.sqlite $ARTIFACT_DIR
echo
echo "Content of artifacts dir $ARTIFACT_DIR:"
ls -lrt $ARTIFACT_DIR
