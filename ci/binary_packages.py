#!/usr/bin/env python3
import argparse

valid_images = ["fedora", "ubuntu", "archlinux", "almalinux", "debian"]


def map_family(image: str) -> str:
	if image in ("almalinux", "centos"):
		return "fedora"
	if image == "ubuntu":
		return "debian"
	return image


def unique_preserve_order(items):
	seen = set()
	out = []
	for item in items:
		if item not in seen:
			seen.add(item)
			out.append(item)
	return out


pkg_sections = {
	"download_unpack": {
		"fedora": ["ca-certificates", "curl", "gzip", "tar"],
		"debian": ["ca-certificates", "curl", "gzip", "tar"],
		"archlinux": ["ca-certificates", "curl", "gzip", "tar"],
	},
	"core_runtime": {
		"fedora": [
			"expat",
			"mariadb-connector-c",
			"sqlite-libs",
			"zlib",
		],
		# ubuntu links libmariadb.so.3 like debian (the g4install base now builds the
		# whole debian family against libmariadb-dev), so the runtime package is libmariadb3.
		"ubuntu": ["libmariadb3", "libexpat1", "libsqlite3-0", "zlib1g"],
		"debian": ["libexpat1", "libmariadb3", "libsqlite3-0", "zlib1g"],
		"archlinux": ["expat", "mariadb-libs", "sqlite", "zlib"],
	},
	"x11_gl": {
		"fedora": [
			"libX11",
			"libXext",
			"libXmu",
			"libXt",
			"mesa-libEGL",
			"mesa-libGL",
		],
		"debian": ["libegl1", "libgl1", "libx11-6", "libxext6", "libxmu6", "libxt6"],
		"archlinux": ["libx11", "libxext", "libxmu", "libxt", "mesa"],
	},
	"qt6": {
		"fedora": ["qt6-qtbase", "qt6-qtsvg"],
		"debian": [
			"libqt6core6t64",
			"libqt6gui6",
			"libqt6opengl6",
			"libqt6openglwidgets6",
			"libqt6sql6",
			"libqt6svg6",
			"libqt6widgets6",
			"libqt6xml6",
		],
		"archlinux": ["qt6-base", "qt6-svg"],
	},
	"other_linked_runtime": {
		"fedora": ["tbb"],
		"debian": ["libtbb12"],
		"archlinux": ["tbb"],
	},
}


def almalinux_adjustments(pkgs: list[str]) -> list[str]:
	# Match the Qt package selectors used by the working g4install AlmaLinux
	# base images. The -devel packages pull in the runtime libraries needed by
	# the tarball while avoiding the unavailable qt6-qtbase runtime selector.
	rep = {
		"qt6-qtbase": "qt6-qtbase-devel",
		"qt6-qtsvg": "qt6-qtsvg-devel",
	}
	out = []
	for p in pkgs:
		out.append(rep.get(p, p))
	return out


def packages_to_be_installed(image: str, tag: str = "") -> str:
	if image not in valid_images:
		raise SystemExit(f"invalid image '{image}'; valid images: {', '.join(sorted(valid_images))}")

	family = map_family(image)
	packages = []
	for section_name, section in pkg_sections.items():
		packages.extend(section.get(image, section.get(family, [])))
	if image == "almalinux":
		packages = almalinux_adjustments(packages)
		packages.append("libglvnd-opengl")

	return " ".join(unique_preserve_order(packages))


def packages_install_command(image: str, tag: str = "") -> str:
	family = map_family(image)
	packages = packages_to_be_installed(image, tag)
	log = "/tmp/clas12tags-binary-packages-install.log"

	if family == "fedora":
		return (
			"RUN /bin/bash -lc 'set -euo pipefail; "
			f"dnf install -y --allowerasing {packages} >{log} 2>&1 "
			f"|| {{ rc=$?; cat {log}; exit $rc; }}'"
		)

	if family == "debian":
		return (
			"ENV DEBIAN_FRONTEND=noninteractive\n"
			"ENV DEBCONF_NONINTERACTIVE_SEEN=true\n"
			"ENV TZ=UTC\n"
			"RUN /bin/bash -lc 'set -euo pipefail; "
			"ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && "
			"apt-get update && "
			f"apt-get install -y --no-install-recommends tzdata {packages} >{log} 2>&1 "
			f"|| {{ rc=$?; cat {log}; exit $rc; }}'"
		)

	if family == "archlinux":
		return (
			"RUN /bin/bash -lc 'set -euo pipefail; "
			f"pacman -Syu --noconfirm --needed {packages} >{log} 2>&1 "
			f"|| {{ rc=$?; cat {log}; exit $rc; }}'"
		)

	return ""


def main():
	parser = argparse.ArgumentParser(description="Return runtime packages for clas12Tags tarball tests")
	parser.add_argument("-i", "--image", required=True, help="Target base OS")
	parser.add_argument("-t", "--tag", default="", help="Target base OS tag")
	parser.add_argument(
		"--command",
		action="store_true",
		help="Print a Dockerfile RUN command instead of the package list",
	)
	args = parser.parse_args()

	if args.command:
		print(packages_install_command(args.image, args.tag))
	else:
		print(packages_to_be_installed(args.image, args.tag))


if __name__ == "__main__":
	main()
