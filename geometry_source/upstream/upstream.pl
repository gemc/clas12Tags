#!/bin/zsh

# Fake perl script to keep the directory structure used to release clas12Tags

cd beampipeUpstream ; perl beampipeUpstream.pl config.dat ; cd ..
cd cndUpstream ; perl cndUpstream.pl config.dat ; cd ..
cd mvtElectronics ; perl mvtElectronics.pl config.dat ; cd ..
cd supportsUpstream ; perl supportsUpstream.pl config.dat ; cd ..
