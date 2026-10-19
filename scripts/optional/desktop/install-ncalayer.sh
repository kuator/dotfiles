#!/usr/bin/env bash

set -euo pipefail

NCALAYER_VERSION="1.4"
NCALAYER_PUBLISHED_SHA1="${NCALAYER_PUBLISHED_SHA1:-ee0219f72b26b23e25d9f26afc246ca14e16c394}"
NCALAYER_SHA256="${NCALAYER_SHA256:-31f47c126fe56107d76f11c446110dfa09fc397f032a54ef8ee4d7bcaf6461cb}"
NCALAYER_URL="https://ncl.pki.gov.kz/images/NCALayer/ncalayer.zip"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
install_parent="${NCALAYER_INSTALL_PARENT:-$XDG_DATA_HOME}"
install_dir="$install_parent/NCALayer"
receipt="$install_dir/.dotfiles-archive-sha256"

if [ -x "$install_dir/ncalayer.sh" ] &&
	[ -x "$install_dir/jre8_ncalayer/bin/java" ] &&
	[ -f "$receipt" ] &&
	[ "$(cat "$receipt")" = "$NCALAYER_SHA256" ]; then
	echo "NCALayer $NCALAYER_VERSION already installed from the pinned archive."
	exit 0
fi

if pgrep -f 'jre8_ncalayer/bin/java.*-jar.*ncalayer[.]sh' >/dev/null 2>&1; then
	echo "NCALayer is running. Stop it before installing or updating." >&2
	exit 1
fi

sudo apt-get install -y libnotify-bin libnss3-tools pcsc-tools xdg-utils xxd

staging_dir="$(mktemp -d)"
cleanup() {
	rm -rf "$staging_dir"
}
trap cleanup EXIT

archive="$staging_dir/ncalayer.zip"
if [ -n "${NCALAYER_ARCHIVE:-}" ]; then
	cp -- "$NCALAYER_ARCHIVE" "$archive"
else
	curl --fail --silent --show-error --location \
		--output "$archive" "$NCALAYER_URL"
fi

printf '%s  %s\n' "$NCALAYER_PUBLISHED_SHA1" "$archive" |
	sha1sum --check --status
printf '%s  %s\n' "$NCALAYER_SHA256" "$archive" |
	sha256sum --check --status

if ! unzip -Z1 "$archive" | awk '
	/^\// || /(^|\/)\.\.($|\/)/ { unsafe = 1 }
	END { exit unsafe }
'; then
	echo "The NCALayer archive contains an unsafe path." >&2
	exit 1
fi

payload="$staging_dir/payload"
mkdir -p "$payload"
unzip -q "$archive" -d "$payload"

for required_path in \
	ncalayer.sh \
	additions/jre8_ncalayer/bin/java \
	additions/ncalayer.png \
	additions/cert/root_rsa.cer \
	additions/cert/nca_rsa.cer; do
	if [ ! -e "$payload/$required_path" ]; then
		printf 'The NCALayer archive is missing %s.\n' "$required_path" >&2
		exit 1
	fi
done
chmod +x "$payload/ncalayer.sh"

mkdir -p "$install_parent"
installer_input="$install_parent"
desktop_entry="$XDG_DATA_HOME/applications/ncalayer.desktop"
if [ -f "$desktop_entry" ]; then
	installer_input="I
$install_parent"
fi

# The vendor text installer exits nonzero after starting NCALayer. Validate the
# resulting installation instead of relying on that exit status. Unlike its GUI
# reinstall path, this text path preserves XDG_CONFIG_HOME/NCALayer modules and
# settings.
set +e
printf '%s\n' "$installer_input" |
	(cd "$payload" && ./ncalayer.sh --nogui)
set -e

if [ ! -x "$install_dir/ncalayer.sh" ] ||
	[ ! -x "$install_dir/jre8_ncalayer/bin/java" ]; then
	echo "NCALayer installation did not produce the expected application files." >&2
	exit 1
fi

installed_version="$({ "$install_dir/ncalayer.sh" --version || true; } |
	sed -n 's/.*= *\([0-9][0-9.]*\).*/\1/p' | head -n 1)"
if [ "$installed_version" != "$NCALAYER_VERSION" ]; then
	printf 'Unexpected NCALayer version after installation: %s\n' \
		"${installed_version:-missing}" >&2
	exit 1
fi

printf '%s\n' "$NCALAYER_SHA256" >"$receipt"
echo "Installed NCALayer $NCALAYER_VERSION in $install_dir."
