#!/bin/csh -f

# script to show differences between source and a tag source
#
# if second option "prompt" is given, then the script will ask for user input
# to copy each file into the tag

# note:
# 1. if gemc.cc has differences other than the tag version, it will be considered as well
# 2. the script will be run one directory up from clas12tags
set prompt = "no"

if( "$1" != "" ) then
	set tagVersion = $1
else
	echo Warning: TAG not given
	exit
endif

if( "$2" == "prompt" ) then
	set prompt = "yes"
endif

echo
echo TAG: $tagVersion
echo Prompt: $prompt
echo


# doing the diff one dir up
cd ..

# diff summary printed on screen. Ignoring objects, moc files, libraries and gemc executable
echo DIFF OUTPUT:
echo
diff -x '*.o' -x 'moc_*.cc' -x '*.a' -x 'gemc' -r -q source clas12Tags/$tagVersion/source | grep -v \.git | grep -v sconsign\.dblite | grep -v gemc\.cc
echo
echo

# assuming format like:
# Files source/utilities/options.h and clas12Tags/4.3.1/source/utilities/options.h differ
# ignoring .o

set sourcesChanged = `diff -x '*.o' -x 'moc_*.cc' -x '*.a' -x 'gemc' -r -q source clas12Tags/$tagVersion/source | grep -v gemc.cc | grep differ | awk '{print $2}'`
set tagFiles       = `diff -x '*.o' -x 'moc_*.cc' -x '*.a' -x 'gemc' -r -q source clas12Tags/$tagVersion/source | grep -v gemc.cc | grep differ | awk '{print $4}'`

echo FILES CHANGED:
set i = 1
foreach file ($sourcesChanged)
	if ($prompt == "no") then
		echo source: $sourcesChanged[$i]", destination: "$tagFiles[$i]
	else
		echo Source: $sourcesChanged[$i]", destination: "$tagFiles[$i] ". Resolve diff (y/n)?"
		set req = $<
		if ($req == "y") then
			cp $sourcesChanged[$i] $tagFiles[$i]
			echo source: $sourcesChanged[$i]" copied to destination: "$tagFiles[$i]
			echo
			echo
		endif
	endif
	@ i += 1
end
echo


# not checking gemc.cc if the version is the only change
set maincc = `diff source/gemc.cc clas12Tags/$tagVersion/source/gemc.cc | grep -v 32c32 | grep -v GEMC_VERSION | grep -v "\-\-\-" | wc | awk '{print $1}'`
# if the differentce is NOT GEMC_VERSION (line 32)
if ("$maincc" != "0") then
	if ($prompt == "no") then
		echo FOUND gemc.cc differences other than the tag version: "$maincc"
		diff source/gemc.cc clas12Tags/$tagVersion/source/gemc.cc | grep -v GEMC\_VERSION
	else
		echo
		echo "gemc.cc has changes. Resolve (y/n)?"
		set req = $<
		if ($req == "y") then
			cp source/gemc.cc clas12Tags/$tagVersion/source/
		endif
	endif
endif

# checking that the right version is on gemc.cc
cd clas12Tags/$tagVersion/source
set GVERSION = `grep GEMC\_VERSION gemc.cc | grep $tagVersion | wc | awk '{print $1}'`
if ($GVERSION != "1") then
	echo gemc tag version is not $tagVersion. Fixing it with
	set newContent1='const char *GEMC_VERSION = "gemc '
	set newContent2=$tagVersion'"'
	set newContent="$newContent1$newContent2 ;"
	echo "$newContent"
	sed -i '' s/"const char .*"/"$newContent"/ gemc.cc
endif

echo
echo changing initializeBMTConstants and initializeFMTConstants to initialize before processID
sed -i '' s/'initializeBMTConstants(-1)'/'initializeBMTConstants(1)'/ hitprocess/clas12/micromegas/BMT_hitprocess.cc
sed -i '' s/'initializeFMTConstants(-1)'/'initializeFMTConstants(1)'/ hitprocess/clas12/micromegas/FMT_hitprocess.cc

echo removing evio support for clas12tags
sed -i '' s/'env = init_environment("qt5 geant4 clhep evio xercesc ccdb mlibrary cadmesh hipo c12bfields")'/'env = init_environment("qt5 geant4 clhep xercesc ccdb mlibrary cadmesh hipo c12bfields")'/ SConstruct
sed -i '' s/'output\/evio_output.cc'/''/ SConstruct

sed -i '' s/'\/\/ EVIO'/''/                                                       output/outputFactory.h
sed -i '' s/'#pragma GCC diagnostic push'/''/                                     output/outputFactory.h
sed -i '' s/'#pragma GCC diagnostic ignored "-Wdeprecated-declarations" '/''/     output/outputFactory.h
sed -i '' s/'#pragma GCC diagnostic ignored "-Wdeprecated"'/''/                   output/outputFactory.h
sed -i '' s/'#include "evioUtil.hxx"'/''/                                         output/outputFactory.h
sed -i '' s/'#include "evioFileChannel.hxx"'/''/                                  output/outputFactory.h
sed -i '' s/'#pragma GCC diagnostic pop'/''/                                      output/outputFactory.h
sed -i '' s/'using namespace evio;'/''/                                           output/outputFactory.h
sed -i '' s/'evioFileChannel \*pchan;'/''/                                        output/outputFactory.h


sed -i '' s/'#include "evio_output.h"'/''/                                                               output/outputFactory.cc
sed -i '' s/'\/\/ EVIO Buffer size set to 30M words'/''/                                                 output/outputFactory.cc
sed -i '' s/'int evio_buffer = EVIO_BUFFER;'/''/                                                         output/outputFactory.cc
sed -i '' s/'if(outType == "evio") {'/'{'/                                                               output/outputFactory.cc
sed -i '' s/'pchan = new evioFileChannel(trimSpacesFromString(outFile).c_str(), "w", evio_buffer);'/''/  output/outputFactory.cc
sed -i '' s/'pchan->open();'/''/                                                                         output/outputFactory.cc
sed -i '' s/'outputMap\["evio"\]       = &evio_output::createOutput;'/''/                                output/outputFactory.cc
sed -i '' s/'pchan->close();'/''/                                                                        output/outputFactory.cc
sed -i '' s/'delete pchan;'/''/                                                                          output/outputFactory.cc
