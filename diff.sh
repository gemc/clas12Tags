#!/bin/zsh

# script to show differences between gemc/source and a clas21Tags/source
#
# the proper version string in gemc.cc is derived by identifying the
# last number in the directory release_notes which contains the <tag>.md files
#
# if the prompt argument is given, then the script will ask for user input
# to copy each file into the tag
#
# if the RELEASE argument is given, the dev.md file will be copied to the next release
prompt="no"

next_release=$(ls release_notes | grep -v dev | grep '.md' | awk -F. '{print $1"."$2}' | sort -V | tail -1)

# check the difference between the dev.md and the next release until the string " # Environment on ifarm / cvmfs" is found
# if the result is different, print a warning
string_dev=$(awk '/# Environment on ifarm \/ cvmfs/{exit} {print}' release_notes/dev.md)
string_next=$(awk '/# Environment on ifarm \/ cvmfs/{exit} {print}' release_notes/$next_release.md)
differences=$(diff <(echo "$string_dev") <(echo "$string_next"))
if [[ $differences ]]; then
	echo
	echo " > WARNING ############################ "
	echo " > WARNING: dev.md and $next_release.md are different. Check the differences"
	echo " > WARNING ############################ "
fi

# if argument is RELEASE, copy dev.md onto the next release
if [[ $# -gt 0 ]]; then
	if [[ $1 == "RELEASE" ]]; then
		cp release_notes/dev.md release_notes/$next_release.md
		sed -i 's/dev/'$next_release'/' "release_notes/$next_release.md"
	fi
fi

if [[ $# -gt 0 ]]; then
	if [[ $1 == "prompt" ]]; then
		prompt="yes"
	fi
fi

ignores="-x .idea -x .git -x .gitignore -x *.o -x moc_*.cc -x *.a -x api -x .sconsign.dblite -x releases"

printf "\nNext release is $yellow$next_release$reset\n"
printf "Ignoring $yellow$ignores$reset\n\n"

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

printf "\n- Changing initializeBMTConstants, initializeFMTConstants, initializeRTPCConstants to initialize before processID"
sed -i s/'initializeBMTConstants(-1)'/'initializeBMTConstants(1)'/ source/hitprocess/clas12/micromegas/BMT_hitprocess.cc
sed -i s/'initializeFMTConstants(-1)'/'initializeFMTConstants(1)'/ source/hitprocess/clas12/micromegas/FMT_hitprocess.cc
sed -i s/'initializeRTPCConstants(-1)'/'initializeRTPCConstants(11)'/ source/hitprocess/clas12/rtpc_hitprocess.cc
