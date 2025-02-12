#!/usr/bin/env zsh

# Purpose: compiles and installs gemc

# Container run:
# docker run -it --rm --platform linux/amd64 jeffersonlab/gemc:dev-fedora36 sh
# git clone http://github.com/gemc/clas12Tags /root/clas12Tags && cd /root/clas12Tags
# ./ci/build_gemc.sh

source ci/env.sh

# get the clas12.sqlite file. This will be replaced by the actual file
cd experiments/clas12
# pipe to null to avoid the output of the wget command
wget https://userweb.jlab.org/~ungaro/tmp/j4np-1.1.1.tar.gz  >/dev/null 2>&1
tar -zxpvf j4np-1.1.1.tar.gz
yum install -y java-latest-openjdk >/dev/null 2>&1