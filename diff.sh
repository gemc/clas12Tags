#!/bin/zsh

# script to show differences between gemc/source and a clas21Tags/source
#
# the proper version string in gemc.cc is derived by identifying the
# last number in the directory release_notes which contains the <tag>.md files
#
# if any argument is given, then the script will ask for user input
# to copy each file into the tag
#
# note: the script is meant to run one directory up from clas12tags
prompt="no"

next_release=$(ls release_notes | grep '.md' | grep -v all | sort -u | tail -1 | awk -F. '{print $1"."$2}')

# if argument is given, set prompt to yes
if [[ $# -gt 0 ]]; then
	prompt="yes"
fi

ignores="-x .idea -x .git -x .gitignore -x *.o -x moc_*.cc -x *.a -x api -x .sconsign.dblite -x releases"

printf "\nNext release is $yellow$next_release$reset\n"
printf "Prompt is $yellow$prompt$reset\n"
printf "Ignoring $yellow$ignores$reset\n\n"

## diff summary printed on screen. Ignoring objects, moc files, libraries and gemc executable
diffs=$(diff -rq $=ignores ../source source | sed 's/Files //g' | sed 's/ and / /g' |  sed 's/ differ//g')

# create an array from diffs where the discriminator is carriage return
diffs=("${(@f)diffs}")

print "\nDiffs:\n"
for d in $diffs; do
	source=$(echo "$d" | awk '{print $1}')
	target=$(echo "$d" | awk '{print $2}')
	if [[ $prompt == "yes" ]]; then
		clear
		printf "\nDiffs of source: $yellow$source$reset with $yellow$target$reset:\n"
		diff $source $target
		printf "\n$magenta Copy? (y/n)$reset\n"
		read -r answer
		echo $answer
		if [[ $answer == "y" ]]; then
			cp $source $target
		fi
	else
		printf "$d\n"
	fi
done


printf "\n- Setting correct version string to $next_release in gemc.cc"
new_string="const char *GEMC_VERSION = \"gemc $next_release\" ;"
sed -i 's/const char.*/'$new_string'/' source/gemc.cc

printf "\n- Changing initializeBMTConstants and initializeFMTConstants to initialize before processID"
sed -i s/'initializeBMTConstants(-1)'/'initializeBMTConstants(1)'/ source/hitprocess/clas12/micromegas/BMT_hitprocess.cc
sed -i s/'initializeFMTConstants(-1)'/'initializeFMTConstants(1)'/ source/hitprocess/clas12/micromegas/FMT_hitprocess.cc

printf "\n- Removing evio support for clas12tags\n\n"
sed -i s/'env = init_environment("qt5 geant4 clhep evio xercesc ccdb mlibrary cadmesh hipo c12bfields")'/'env = init_environment("qt5 geant4 clhep xercesc ccdb mlibrary cadmesh hipo c12bfields")'/ source/SConstruct
sed -i s/'output\/evio_output.cc'/''/ source/SConstruct


sed -i s/'\/\/ EVIO'/''/                                                       source/output/outputFactory.h
sed -i s/'#pragma GCC diagnostic push'/''/                                     source/output/outputFactory.h
sed -i s/'#pragma GCC diagnostic ignored "-Wdeprecated-declarations" '/''/     source/output/outputFactory.h
sed -i s/'#pragma GCC diagnostic ignored "-Wdeprecated"'/''/                   source/output/outputFactory.h
sed -i s/'#include "evioUtil.hxx"'/''/                                         source/output/outputFactory.h
sed -i s/'#include "evioFileChannel.hxx"'/''/                                  source/output/outputFactory.h
sed -i s/'#pragma GCC diagnostic pop'/''/                                      source/output/outputFactory.h
sed -i s/'using namespace evio;'/''/                                           source/output/outputFactory.h
sed -i s/'evioFileChannel \*pchan;'/''/                                        source/output/outputFactory.h


sed -i s/'#include "evio_output.h"'/''/                                                               source/output/outputFactory.cc
sed -i s/'\/\/ EVIO Buffer size set to 30M words'/''/                                                 source/output/outputFactory.cc
sed -i s/'int evio_buffer = EVIO_BUFFER;'/''/                                                         source/output/outputFactory.cc
sed -i s/'if(outType == "evio") {'/'{'/                                                               source/output/outputFactory.cc
sed -i s/'pchan = new evioFileChannel(trimSpacesFromString(outFile).c_str(), "w", evio_buffer);'/''/  source/output/outputFactory.cc
sed -i s/'pchan->open();'/''/                                                                         source/output/outputFactory.cc
sed -i s/'outputMap\["evio"\]       = &evio_output::createOutput;'/''/                                source/output/outputFactory.cc
sed -i s/'pchan->close();'/''/                                                                        source/output/outputFactory.cc
sed -i s/'delete pchan;'/''/                                                                          source/output/outputFactory.cc
