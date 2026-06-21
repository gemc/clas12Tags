#!/usr/bin/env python3
import argparse
import sys

from binary_packages import map_family, packages_install_command


def dockerfile(image: str, tag: str) -> str:
	family = map_family(image)
	lines = [
		f"FROM {image}:{tag}",
		'SHELL ["/bin/bash", "-c"]',
	]

	if family == "archlinux":
		lines.append("RUN pacman-key --init && pacman-key --populate")
		lines.append("RUN pacman -Sy --noconfirm archlinux-keyring")
	elif image == "almalinux":
		lines.append("RUN dnf install -y 'dnf-command(config-manager)' \\")
		lines.append("    && dnf config-manager --set-enabled crb \\")
		lines.append("    && dnf install -y almalinux-release-synergy")

	lines.append(packages_install_command(image, tag))
	return "\n".join(lines)


def main() -> int:
	parser = argparse.ArgumentParser(description="Generate a clas12Tags binary tarball test Dockerfile")
	parser.add_argument("-i", "--image", required=True, help="Target base OS")
	parser.add_argument("-t", "--tag", required=True, help="Target base OS tag")
	args = parser.parse_args()

	print(dockerfile(args.image, args.tag))
	return 0


if __name__ == "__main__":
	sys.exit(main())
