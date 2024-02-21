#!/usr/bin/env python3


# cat all files listed in release_order.dat
# into a file called all_releases.md

import os

# Get the current directory
current_dir = os.getcwd()

# reads the content of release_order.dat
# and assign the values to a list
print("\n > Reading release_order.dat\n")
release_order_file = os.path.join(current_dir, "release_order.dat")
release_order_list = []
with open(release_order_file, "r") as file:
	for line in file:
		line = line.strip()
		if line != "":
			release_order_list.append(line)

# Create the all_releases.md file
all_releases_file = os.path.join(current_dir, "all_releases.md")
with open(all_releases_file, "w") as file:
	for release in release_order_list:
		release_file = os.path.join(current_dir, release)
		with open(release_file, "r") as rfile:
			file.write(rfile.read())
			file.write("\n\n")
			print(" > ", release)


