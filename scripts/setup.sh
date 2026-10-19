#!/usr/bin/env bash

set -euo pipefail

os_release_file="${OS_RELEASE_FILE:-/etc/os-release}"
if [ ! -r "$os_release_file" ]; then
	echo "Cannot identify this operating system." >&2
	exit 1
fi

. "$os_release_file"

if [ "${ID:-}" != ubuntu ]; then
	echo "This bootstrap supports Ubuntu only." >&2
	exit 1
fi

case "${VERSION_ID:-}:${XDG_CURRENT_DESKTOP:-}" in
24.04:*Cinnamon* | 26.04:*KDE*) ;;
*)
	printf 'Unsupported platform: Ubuntu %s with %s.\n' \
		"${VERSION_ID:-unknown}" "${XDG_CURRENT_DESKTOP:-unknown}" >&2
	exit 1
	;;
esac

scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$scripts_dir")"
export DOTFILES
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

"$scripts_dir/bootstrap/install-packages.sh"
"$scripts_dir/bootstrap/install-appgate.sh"
"$scripts_dir/bootstrap/install-bitwarden.sh"
"$scripts_dir/bootstrap/install-ghostty.sh"
"$scripts_dir/bootstrap/install-teams-for-linux.sh"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME/zinit"
zinit_home="$XDG_DATA_HOME/zinit/zinit.git"
if [ ! -f "$zinit_home/zinit.zsh" ]; then
	git clone https://github.com/zdharma-continuum/zinit "$zinit_home"
fi

"$scripts_dir/bootstrap/link-configs.sh"
"$scripts_dir/bootstrap/install-mise.sh"
"$scripts_dir/bootstrap/install-textractor.sh"
"$scripts_dir/bootstrap/install-subtitle-sync.sh"
"$scripts_dir/bootstrap/install-leetcode-anki.sh"
"$scripts_dir/bootstrap/install-window-tray.sh"

"$scripts_dir/bootstrap/configure-desktop.sh"

echo "Bootstrap complete. Start a new login shell to load the configuration."
