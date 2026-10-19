#!/usr/bin/env bash

set -euo pipefail

TEAMS_FOR_LINUX_VERSION="2.8.0"
TEAMS_FOR_LINUX_SHA256="c3fafdc32f1d0fff5b40c47c06457e7edfb9c7936a7ce35ed9cf7824dab6c89f"
TEAMS_FOR_LINUX_DEB_URL="https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v${TEAMS_FOR_LINUX_VERSION}/teams-for-linux_${TEAMS_FOR_LINUX_VERSION}_amd64.deb"

architecture="${DEB_ARCHITECTURE:-$(dpkg --print-architecture)}"
if [ "$architecture" != amd64 ]; then
	printf 'Unsupported architecture for the pinned Teams-for-Linux package: %s\n' \
		"$architecture" >&2
	exit 1
fi

installed_version="$(dpkg-query -W -f='${Version}' teams-for-linux 2>/dev/null || true)"
if [ "$installed_version" = "$TEAMS_FOR_LINUX_VERSION" ]; then
	echo "Teams-for-Linux $installed_version already installed."
	exit 0
fi

if [ -n "$installed_version" ]; then
	printf 'Teams-for-Linux %s is installed; expected %s. Refusing to change the deliberately pinned version.\n' \
		"$installed_version" "$TEAMS_FOR_LINUX_VERSION" >&2
	exit 1
fi

staging_dir="$(mktemp -d)"
cleanup() {
	rm -rf "$staging_dir"
}
trap cleanup EXIT

deb="$staging_dir/teams-for-linux_${TEAMS_FOR_LINUX_VERSION}_amd64.deb"
curl --fail --silent --show-error --location \
	--output "$deb" "$TEAMS_FOR_LINUX_DEB_URL"
printf '%s  %s\n' "$TEAMS_FOR_LINUX_SHA256" "$deb" |
	sha256sum --check --status

package="$(dpkg-deb -f "$deb" Package)"
package_version="$(dpkg-deb -f "$deb" Version)"
package_architecture="$(dpkg-deb -f "$deb" Architecture)"
if [ "$package" != teams-for-linux ] ||
	[ "$package_version" != "$TEAMS_FOR_LINUX_VERSION" ] ||
	[ "$package_architecture" != amd64 ]; then
	printf 'Unexpected Teams-for-Linux package metadata: %s %s %s\n' \
		"$package" "$package_version" "$package_architecture" >&2
	exit 1
fi

sudo apt-get install -y "$deb"

installed_version="$(dpkg-query -W -f='${Version}' teams-for-linux)"
if [ "$installed_version" != "$TEAMS_FOR_LINUX_VERSION" ]; then
	printf 'Unexpected Teams-for-Linux version after installation: %s\n' \
		"$installed_version" >&2
	exit 1
fi

echo "Installed Teams-for-Linux $TEAMS_FOR_LINUX_VERSION."
