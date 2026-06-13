#!/usr/bin/env python3

valid_images = ["fedora", "ubuntu", "archlinux", "almalinux", "debian"]
g4_registry = "ghcr.io/gemc/g4install"


def is_valid_image(image: str) -> bool:
	if image in valid_images:
		return True
	else:
		print(f"Error: invalid image '{image}'")
		print(f"Valid images: {available_images()}")
		exit(1)


def available_images() -> str:
	return ", ".join(sorted(valid_images))


def remote_startup_dir() -> str:
	return "/usr/local/bin"


def remote_entrypoint():
	return f"{remote_startup_dir()}/docker-entrypoint.sh"


def remote_entrypoint_addon():
	return f"{remote_startup_dir()}/additional-entrycommands.sh"


# almalinux requires explicit JAVA_HOME
def docker_header(image: str, image_tag: str, geant4_tag: str) -> str:
	commands = f"FROM {g4_registry}:{geant4_tag}-{image}-{image_tag} AS final\n"
	commands += 'LABEL maintainer="Maurizio Ungaro <ungaro@jlab.org>"\n\n'
	commands += "# run bash instead of sh\n"
	commands += 'SHELL ["/bin/bash", "-c"]\n\n'
	commands += "ENV AUTOBUILD=1\n"
	if image == "almalinux":
		commands += "ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk\n"
		commands += 'ENV PATH="${JAVA_HOME}/bin:${PATH}"\n'
	return commands


def coatjava_deps(image: str) -> str:
	"""
	coatjava dependencies + Groovy (tarball/zip) install.
	Installs:
	  - maven, jq
	  - perl DBI, DBD::SQLite, XML::LibXML
	  - curl, unzip
	  - Groovy into /usr/local/groovy, symlink /usr/bin/groovy
	"""
	groovy_version = '5.0.4'
	groovy_zip = f'apache-groovy-binary-{groovy_version}.zip'
	groovy_url = f'https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/{groovy_zip}'
	groovy_dir = f'groovy-{groovy_version}'

	if image in ("fedora", "almalinux"):
		pkg_install = (
			"dnf -y install --allowerasing "
			"maven jq perl perl-DBI perl-DBD-SQLite perl-XML-LibXML curl unzip"
		)
		pkg_clean = (
			"dnf -y clean all && rm -rf /var/cache/dnf"
		)

	elif image in ("ubuntu", "debian"):
		pkg_install = (
			"apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "
			"maven jq libdbi-perl libdbd-sqlite3-perl libxml-libxml-perl curl unzip ca-certificates"
		)
		pkg_clean = "rm -rf /var/lib/apt/lists/*"

	elif image == "archlinux":
		pkg_install = (
			"pacman -Syu --noconfirm && pacman -S --noconfirm --needed "
			"maven jq perl-dbi perl-dbd-sqlite perl-xml-libxml curl unzip"
		)
		pkg_clean = "pacman -Scc --noconfirm"

	else:
		# Should be unreachable if you validate images earlier.
		return "\n# coatjava deps: (unsupported image)\n"

	return (
		"\n# coatjava dependencies + Groovy (tarball/zip)\n"
		"RUN set -euo pipefail \\\n"
		f" && {pkg_install} \\\n"
		f" && curl -L -o {groovy_zip} {groovy_url} \\\n"
		f" && unzip -q {groovy_zip} \\\n"
		f" && rm -f {groovy_zip} \\\n"
		f" && rm -rf /usr/local/groovy \\\n"
		f" && mv {groovy_dir} /usr/local/groovy \\\n"
		f" && ln -sf /usr/local/groovy/bin/groovy /usr/bin/groovy \\\n"
		f" && {pkg_clean}\n"
	)


def additional_software(image: str) -> str:
	"""
	Install extra tooling: Java 21 + git-lfs.
	Distro-specific package managers are handled here.
	"""
	if image in ("ubuntu", "debian"):
		# git-lfs is in the standard repos for modern Ubuntu/Debian.
		return (
			"\n# Additional software: Java 21 + git-lfs\n"
			"RUN set -euo pipefail \\\n"
			" && apt-get update \\\n"
			" && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n"
			"      openjdk-21-jdk \\\n"
			"      git-lfs \\\n"
			"      ca-certificates \\\n"
			" && git lfs install --system \\\n"
			" && rm -rf /var/lib/apt/lists/*\n"
		)

	if image == "fedora":
		return (
			"\n# Additional software: Java 21 + git-lfs\n"
			"RUN set -euo pipefail \\\n"
			" && (dnf -y install java-21-openjdk-devel || dnf -y install java-latest-openjdk-devel) \\\n"
			" && dnf -y install git-lfs \\\n"
			" && git lfs install --system \\\n"
			" && printf 'class JdkCheck {}\\n' > /tmp/JdkCheck.java \\\n"
			" && javac --release 21 /tmp/JdkCheck.java \\\n"
			" && rm -f /tmp/JdkCheck.java /tmp/JdkCheck.class \\\n"
			" && dnf -y clean all \\\n"
			" && rm -rf /var/cache/dnf\n"
		)

	if image == "almalinux":
		return (
			"\n# Additional software: Java 21 + git-lfs\n"
			"RUN set -euo pipefail \\\n"
			" && dnf -y install java-21-openjdk-devel \\\n"
			" && (dnf -y install git-lfs || (dnf -y install epel-release && dnf -y install git-lfs)) \\\n"
			" && git lfs install --system \\\n"
			" && JAVA21_BIN=$(rpm -ql java-21-openjdk-headless java-21-openjdk-devel 2>/dev/null \\\n"
			"      | grep -E '/bin/java$' | head -n 1) \\\n"
			" && test -n \"${JAVA21_BIN}\" \\\n"
			" && JAVA21_DIR=$(dirname \"${JAVA21_BIN}\") \\\n"
			" && JAVA21_HOME=$(dirname \"${JAVA21_DIR}\") \\\n"
			" && ln -sfn \"${JAVA21_HOME}\" /usr/lib/jvm/java-21-openjdk \\\n"
			" && ln -sf \"${JAVA21_BIN}\" /usr/bin/java \\\n"
			" && test -x \"${JAVA21_DIR}/javac\" \\\n"
			" && ln -sf \"${JAVA21_DIR}/javac\" /usr/bin/javac \\\n"
			" && java -version \\\n"
			" && javac -version \\\n"
			" && dnf -y clean all \\\n"
			" && rm -rf /var/cache/dnf\n"
		)

	if image == "archlinux":
		return (
			"\n# Additional software: Java 21 + git-lfs\n"
			"RUN set -euo pipefail \\\n"
			" && pacman_install() { \\\n"
			"      pacman -Syu --noconfirm --needed \"$@\" \\\n"
			"        || (pacman -Syy --noconfirm && pacman -S --noconfirm --needed \"$@\"); \\\n"
			"    } \\\n"
			" && pacman_install jdk21-openjdk git-lfs \\\n"
			" && git lfs install --system \\\n"
			" && pacman -Scc --noconfirm\n"
		)

	return "\n# Additional software: (none)\n"


def install_gemc(geant4_version: str, gemc_version: str, source: str = "clone") -> str:
	if source == "context":
		commands = (
			"\nCOPY . /root/clas12Tags\n"
			"RUN  cd /root/clas12Tags \\\n"
			f"     && DOCKER_ENTRYPOINT_SOURCE_ONLY=1 . {remote_entrypoint()} \\\n"
			f"     && module load geant4/{geant4_version} \\\n"
			f"     && ./ci/build.sh \\\n"
			f'     && echo "export PATH=\\${{SIM_HOME}}/clas12Tags/dev/bin:\\${{PATH}}" >> {remote_entrypoint_addon()}\n'
		)
		return commands

	clone_arguments = '-c advice.detachedHead=false --recurse-submodules --single-branch'
	if gemc_version == "dev":
		clone_arguments += " --depth 1"
		clone_arguments += ' --branch meson'
	else:
		clone_arguments += f' --branch "{gemc_version}"'

	commands = (
		f"\nRUN  git clone {clone_arguments} http://github.com/gemc/clas12Tags /root/clas12Tags \\\n"
		f"     && cd /root/clas12Tags \\\n"
		f"     && DOCKER_ENTRYPOINT_SOURCE_ONLY=1 . {remote_entrypoint()} \\\n"
		f"     && module load geant4/{geant4_version} \\\n"
		f"     && ./ci/build.sh \\\n"
		f'     && echo "export PATH=\\${{SIM_HOME}}/clas12Tags/dev/bin:\\${{PATH}}" >> {remote_entrypoint_addon()}\n'
	)
	return commands


def package_install(
	geant4_version: str,
	gemc_version: str,
	image: str,
	image_tag: str,
	package_arch: str,
) -> str:
	package_name = f"clas12Tags-{gemc_version}-geant4-{geant4_version}-{image}-{image_tag}"
	package_name += f"-{package_arch}"
	commands = "\n# release tarball build \n"
	commands += "FROM final AS package-build \n"
	commands += "RUN  cd /root/clas12Tags \\\n"
	commands += f"     && DOCKER_ENTRYPOINT_SOURCE_ONLY=1 . {remote_entrypoint()} \\\n"
	commands += f"     && module load geant4/{geant4_version} \\\n"
	commands += "     && eval \"$(geant4-config --sh)\" \\\n"
	commands += f"     && GEANT4_VERSION={geant4_version} CLAS12TAGS_PACKAGE_VERSION={gemc_version} \\\n"
	commands += (
		f"        bash ./ci/package_install.sh \"${{SIM_HOME}}/clas12Tags/dev\" "
		f"/root/clas12Tags/dist \"{package_name}\" \n"
	)
	return commands


def log_exporters() -> str:
	commands = "\n# logs exporter \n"
	commands += "FROM scratch AS logs-export \n"
	commands += "COPY --from=final /root/clas12Tags/logs /logs \n"
	return commands


def package_exporters() -> str:
	commands = "\n# release package exporter \n"
	commands += "FROM scratch AS package-export \n"
	commands += "COPY --from=package-build /root/clas12Tags/dist / \n"
	return commands


def create_dockerfile(
	image: str,
	image_tag: str,
	geant4_version: str,
	gemc_version: str,
	source: str = "clone",
	with_package: bool = False,
	package_arch: str = "amd64",
) -> str:
	commands = ""
	commands += docker_header(image, image_tag, geant4_version)
	commands += coatjava_deps(image)  # maven/jq/perl deps + Groovy
	commands += additional_software(image)  # Java 21 + git-lfs
	commands += "\nRUN java -version 2>&1 | head -n 1 && javac -version 2>&1 | head -n 1\n"
	commands += install_gemc(geant4_version, gemc_version, source)
	commands += log_exporters()
	if with_package:
		commands += package_install(geant4_version, gemc_version, image, image_tag, package_arch)
		commands += package_exporters()
	return commands


import argparse
import sys


def main():
	parser = argparse.ArgumentParser(
		description=(
			"Print a dockerfile with install commands for a given base image and tag, gemc and "
			"geant4 versions"
		),
		epilog=(
			"Example: python3 ./ci/dockerfile_creator.py -i fedora -t 40 "
			"--geant4-version 11.4.0 --gemc-version dev"
		),
	)
	parser.add_argument(
		"-i",
		"--image",
		help="Target base os (e.g., fedora, almalinux, ubuntu, debian, archlinux)",
	)
	parser.add_argument(
		"-t",
		"--image_tag",
		help="Base image tag (e.g., 40 for fedora, 24.04 for ubuntu, etc.)",
	)
	parser.add_argument(
		"--geant4-version",
		default="11.4.0",
		help="Version of Geant4 to install (default: %(default)s)",
	)
	parser.add_argument(
		"--gemc-version",
		default="dev",
		help="Version of GEMC to install (default: %(default)s)",
	)
	parser.add_argument(
		"--source",
		choices=["clone", "context"],
		default="clone",
		help="Build clas12Tags from a GitHub clone or from the Docker build context (default: %(default)s)",
	)
	parser.add_argument(
		"--with-package",
		action="store_true",
		help="Add a package-export stage that emits a clas12Tags install tarball",
	)
	parser.add_argument(
		"--package-arch",
		choices=["amd64", "arm64"],
		default="amd64",
		help="Architecture suffix to use in the package artifact name",
	)

	args = parser.parse_args()

	if not args.image or not args.image_tag:
		parser.print_usage(sys.stderr)
		sys.exit(2)

	is_valid_image(args.image)

	dockerfile = create_dockerfile(
		args.image,
		args.image_tag,
		args.geant4_version,
		args.gemc_version,
		args.source,
		args.with_package,
		args.package_arch,
	)
	print(dockerfile)


if __name__ == "__main__":
	main()
