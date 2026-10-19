#!/usr/bin/env bash

set -euo pipefail

GHOSTTY_UBUNTU_2404_VERSION="1.3.1-0~ppa1"
GHOSTTY_UBUNTU_2404_SHA256="c838f69c6a047eb9d648f9d68502db783102e981d965a3a6ce416e1c07bdbacd"
GHOSTTY_UBUNTU_2404_DEB_URL="https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.3.1-0-ppa1/ghostty_1.3.1-0.ppa1_amd64_24.04.deb"
GHOSTTY_NIGHTLY_PPA="ppa:mkasberg/ghostty-ubuntu-nightly"
ghostty_channel="${GHOSTTY_CHANNEL:-stable}"

case "$ghostty_channel" in
stable | nightly) ;;
*)
	printf 'Unsupported Ghostty channel: %s (expected stable or nightly)\n' \
		"$ghostty_channel" >&2
	exit 1
	;;
esac

os_release_file="${OS_RELEASE_FILE:-/etc/os-release}"
if [ ! -r "$os_release_file" ]; then
	echo "Cannot identify this operating system." >&2
	exit 1
fi

. "$os_release_file"

if [ "${ID:-}" != ubuntu ]; then
	echo "The Ghostty installer supports Ubuntu only." >&2
	exit 1
fi

architecture="${DEB_ARCHITECTURE:-$(dpkg --print-architecture)}"
if [ "$architecture" != amd64 ]; then
	printf 'Unsupported architecture for the Ghostty installer: %s\n' \
		"$architecture" >&2
	exit 1
fi

installed_version="${GHOSTTY_INSTALLED_VERSION:-}"
if [ -z "$installed_version" ]; then
	installed_version="$(dpkg-query -W -f='${Version}' ghostty 2>/dev/null || true)"
fi

case "${VERSION_ID:-}" in
24.04)
	if [ "$ghostty_channel" = nightly ]; then
		echo "Ghostty nightly packages are unavailable for Ubuntu 24.04; use the stable channel or Kubuntu 26.04." >&2
		exit 1
	fi

	if [ -n "$installed_version" ] &&
		dpkg --compare-versions "$installed_version" ge "$GHOSTTY_UBUNTU_2404_VERSION"; then
		echo "Ghostty $installed_version already installed."
		exit 0
	fi

	staging_dir="$(mktemp -d)"
	cleanup() {
		rm -rf "$staging_dir"
	}
	trap cleanup EXIT

	deb="$staging_dir/ghostty_1.3.1-0.ppa1_amd64_24.04.deb"
	curl --fail --silent --show-error --location \
		--output "$deb" "$GHOSTTY_UBUNTU_2404_DEB_URL"
	printf '%s  %s\n' "$GHOSTTY_UBUNTU_2404_SHA256" "$deb" |
		sha256sum --check --status

	package="$(dpkg-deb -f "$deb" Package)"
	package_version="$(dpkg-deb -f "$deb" Version)"
	package_architecture="$(dpkg-deb -f "$deb" Architecture)"
	if [ "$package" != ghostty ] ||
		[ "$package_version" != "$GHOSTTY_UBUNTU_2404_VERSION" ] ||
		[ "$package_architecture" != amd64 ]; then
		printf 'Unexpected Ghostty package metadata: %s %s %s\n' \
			"$package" "$package_version" "$package_architecture" >&2
		exit 1
	fi

	sudo apt-get install -y "$deb"
	;;
26.04)
	apt_sources_dir="${APT_SOURCES_DIR:-/etc/apt/sources.list.d}"
	if [ "$ghostty_channel" = nightly ]; then
		if ! grep -Rqs 'mkasberg.*ghostty-ubuntu-nightly' "$apt_sources_dir"; then
			sudo add-apt-repository --yes --no-update "$GHOSTTY_NIGHTLY_PPA"
		fi
		sudo apt-get update
		sudo apt-get install -y ghostty
	else
		if grep -Rqs 'mkasberg.*ghostty-ubuntu-nightly' "$apt_sources_dir"; then
			sudo add-apt-repository --yes --no-update --remove \
				"$GHOSTTY_NIGHTLY_PPA"
		fi
		sudo apt-get update
		sudo apt-get install -y --allow-downgrades ghostty
	fi
	;;
*)
	printf 'Unsupported Ubuntu version for Ghostty: %s\n' \
		"${VERSION_ID:-unknown}" >&2
	exit 1
	;;
esac

installed_version="${GHOSTTY_INSTALLED_VERSION:-}"
if [ -z "$installed_version" ]; then
	installed_version="$(dpkg-query -W -f='${Version}' ghostty)"
fi
case "${VERSION_ID:-}:$ghostty_channel:$installed_version" in
24.04:stable:"$GHOSTTY_UBUNTU_2404_VERSION" | 26.04:nightly:*+nightly*) ;;
26.04:stable:*)
	case "$installed_version" in
	*+nightly* | "")
		printf 'Unexpected Ghostty stable version after installation: %s\n' \
			"${installed_version:-missing}" >&2
		exit 1
		;;
	esac
	;;
*)
	printf 'Unexpected Ghostty version after installation: %s\n' \
		"$installed_version" >&2
	exit 1
	;;
esac

echo "Installed Ghostty $installed_version from the $ghostty_channel channel."
