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


def docker_header(image: str, image_tag: str, geant4_tag: str) -> str:
    commands = f"FROM {g4_registry}:{geant4_tag}-{image}-{image_tag} AS final\n"
    commands += 'LABEL maintainer="Maurizio Ungaro <ungaro@jlab.org>"\n\n'
    commands += "# run bash instead of sh\n"
    commands += 'SHELL ["/bin/bash", "-c"]\n\n'
    commands += "ENV AUTOBUILD=1\n"
    return commands

def coatjava_deps(image: str) -> str:
    """
    coatjava dependencies + Groovy (tarball/zip) install.
    Installs:
      - maven, jq
      - perl DBI, DBD::SQLite, XML::LibXML
      - curl, unzip
      - Groovy 4.0.26 into /usr/local/groovy, symlink /usr/bin/groovy
    """
    groovy_zip = "apache-groovy-binary-4.0.26.zip"
    groovy_url = f"https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/{groovy_zip}"
    groovy_dir = "groovy-4.0.26"

    if image in ("fedora", "almalinux"):
        pkg_install = (
            "dnf -y install --allowerasing "
            "maven jq perl-DBI perl-DBD-SQLite perl-XML-LibXML curl unzip"
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
    if image == "ubuntu":
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

    if image == "debian":
        # Debian stable may not ship openjdk-21-jdk in main; use backports if needed.
        return (
            "\n# Additional software: Java 21 + git-lfs (Debian uses backports if needed)\n"
            "RUN set -euo pipefail \\\n"
            " && . /etc/os-release \\\n"
            " && apt-get update \\\n"
            " && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\\n"
            "      ca-certificates \\\n"
            "      git-lfs \\\n"
            " && (DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-21-jdk \\\n"
            "     || (echo \"deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main\" > /etc/apt/sources.list.d/backports.list \\\n"
            "         && apt-get update \\\n"
            "         && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -t ${VERSION_CODENAME}-backports openjdk-21-jdk)) \\\n"
            " && git lfs install --system \\\n"
            " && rm -rf /var/lib/apt/lists/*\n"
        )

    if image == "fedora":
        return (
            "\n# Additional software: Java 21 + git-lfs\n"
            "RUN set -euo pipefail \\\n"
            " && dnf -y install \\\n"
            "      java-21-openjdk-devel \\\n"
            "      git-lfs \\\n"
            " && git lfs install --system \\\n"
            " && dnf -y clean all \\\n"
            " && rm -rf /var/cache/dnf\n"
        )

    if image == "almalinux":
        return (
            "\n# Additional software: Java 21 + git-lfs\n"
            "RUN set -euo pipefail \\\n"
            " && dnf -y install java-21-openjdk-devel || true \\\n"
            " && (dnf -y install git-lfs || (dnf -y install epel-release && dnf -y install git-lfs)) \\\n"
            " && git lfs install --system \\\n"
            " && dnf -y clean all \\\n"
            " && rm -rf /var/cache/dnf\n"
        )

    if image == "archlinux":
        return (
            "\n# Additional software: Java 21 + git-lfs\n"
            "RUN set -euo pipefail \\\n"
            " && pacman -Syu --noconfirm \\\n"
            " && pacman -S --noconfirm --needed \\\n"
            "      jdk21-openjdk \\\n"
            "      git-lfs \\\n"
            " && git lfs install --system \\\n"
            " && pacman -Scc --noconfirm\n"
        )

    return "\n# Additional software: (none)\n"


def install_gemc(geant4_version: str, gemc_version: str) -> str:
    clone_arguments = '-c advice.detachedHead=false --recurse-submodules --single-branch'
    if gemc_version == "dev":
        clone_arguments += " --depth 1"
        clone_arguments += f' --branch meson'
    else:
        clone_arguments += f' --branch "{gemc_version}"'

    commands = (
        f"\nRUN  git clone {clone_arguments} http://github.com/gemc/clas12Tags /root/clas12Tags \\\n"
        f"     && cd /root/clas12Tags \\\n"
        f"     && DOCKER_ENTRYPOINT_SOURCE_ONLY=1 . {remote_entrypoint()} \\\n"
        f"     && module load geant4/{geant4_version} \\\n"
        f"     && ./ci/build_gemc.sh \\\n"
        f'     && echo "module load gemc" >> {remote_entrypoint_addon()}\n'
    )
    return commands


def log_exporters() -> str:
    commands = "\n# logs exporter \n"
    commands += "FROM scratch AS logs-export \n"
    commands += "COPY --from=final /root/clas12Tags/logs /logs \n"
    return commands


def create_dockerfile(image: str, image_tag: str, geant4_version: str, gemc_version: str) -> str:
    commands = ""
    commands += docker_header(image, image_tag, geant4_version)
    commands += additional_software(image)     # Java 21 + git-lfs
    commands += coatjava_deps(image)           # maven/jq/perl deps + Groovy
    commands += install_gemc(geant4_version, gemc_version)
    commands += log_exporters()
    return commands


import argparse
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Print a dockerfile with install commands for a given base image and tag, gemc and geant4 versions",
        epilog="Example: python3 ./ci/dockerfile_creator.py -i fedora -t 40 --geant4-version 11.4.0 --gemc-version dev",
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
    )
    print(dockerfile)


if __name__ == "__main__":
    main()