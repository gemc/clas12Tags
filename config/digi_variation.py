#!/usr/bin/python3

# write python code to extract the digitization variation from the gcard files

import glob

files = glob.glob('*_binaryField.gcard')

# loop over all the files in the array "files"
# select the line containing the string DIGITIZATION_VARIATION
for file in files:
	with open(file, 'r') as f:
		root_filename = file.split('_binaryField.gcard')[0]
		lines = f.readlines()
		for line in lines:
			if 'DIGITIZATION_VARIATION' in line:
				variation = line.split('value')[1].split('"')[1]
				print("        if self.configuration == \"" + root_filename + "\":\n          self.digi_variation = \'" + variation + "\'")

