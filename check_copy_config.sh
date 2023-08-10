#!/usr/bin/env zsh

# script will:
#
# 1. apply the tag to the config files
# 2. show the current differences between config (_binary) and clas12-config (no _bimary)
# 3. if `copy` second argument is given, copy the files to clas12-config

# tag option is mandatory, copy is optional
function help() {
  echo
  echo "Syntax: copyConfig.sh [-h|t|c]"
  echo
  echo "Options:"
  echo
  echo "-h: Print this Help."
  echo "-t: tag to be used"
  echo "-c: copy files to clas12-config"
  echo
}

tagVersion="na"
copy="no"

if [ $# -eq 0 ]; then
  help
  exit 1
fi

# merge options
while getopts ":ht:c" option; do
  case $option in
  h)
    help
    exit
    ;;
  t)
    tagVersion=$OPTARG
    ;;
  c)
    copy="yes"
    ;;
  \?) # Invalid option
    echo "Error: Invalid option"
    exit 1
    ;;
  esac
done


# if  tagVersion is `na`, exit
if [[ "$tagVersion" == "na" ]]; then
  echo "Error: tagVersion not given"
  help
  exit 1
fi

echo
echo "> TAG: $tagVersion"
echo "> Copy: $copy"
echo

rm -rf tmp
mkdir tmp


# loop over files inside config dir with extension `binaryField.gcard`
for file in config/*_binaryField.gcard; do


  # get the filename without extension and remove binaryField from name
  filename=$(basename -- "$file")
  filename="${filename%.*}"
  filename="${filename%_binaryField}"

  echo "File: $file, base: $filename"


  # apply the tag to the file
  sed "s/CLAS12TAG/$tagVersion/g" $file >tmp/$filename.gcard

done

echo "\n Diff:"
diff -r  tmp /opt/projects/clas12-config/gemc/$tagVersion


