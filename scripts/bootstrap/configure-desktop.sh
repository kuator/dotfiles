#!/usr/bin/env bash

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
keyboard_config="$repo/configs/system/keyboard"
xkb_symbols="$repo/configs/system/xkb/symbols/en"
cpu_energy_config="$repo/configs/system/tmpfiles.d/cpu-energy-preference.conf"
cpufreq_root="${CPUFREQ_ROOT:-/sys/devices/system/cpu/cpufreq}"
. "$keyboard_config"
sudo install -m 644 "$xkb_symbols" /usr/share/X11/xkb/symbols/en
sudo install -m 644 "$keyboard_config" /etc/default/keyboard
sudo install -m 644 "$cpu_energy_config" \
	/etc/tmpfiles.d/cpu-energy-preference.conf

cpu_supports_balance_performance() {
	local policy_dir
	local preference_file
	local policy_dirs=("$cpufreq_root"/policy*)

	[ -d "${policy_dirs[0]}" ] || return 1
	for policy_dir in "${policy_dirs[@]}"; do
		preference_file="$policy_dir/energy_performance_available_preferences"
		[ -r "$preference_file" ] || return 1
		grep -qw balance_performance "$preference_file" || return 1
	done
}

if cpu_supports_balance_performance; then
	sudo systemd-tmpfiles --create \
		/etc/tmpfiles.d/cpu-energy-preference.conf
else
	echo "CPU does not advertise balance_performance; leaving its energy preference unchanged."
fi

configure_cinnamon() {
	if command -v gsettings >/dev/null; then
		if gsettings list-schemas | grep -qx org.freedesktop.ibus.general; then
			gsettings set org.freedesktop.ibus.general use-system-keyboard-layout true
		fi

		if gsettings list-schemas | grep -qx org.cinnamon.desktop.input-sources; then
			gsettings reset org.cinnamon.desktop.input-sources sources
			gsettings reset org.cinnamon.desktop.input-sources xkb-options
		fi

		if gsettings list-schemas | grep -qx org.gnome.libgnomekbd.keyboard; then
			gsettings reset org.gnome.libgnomekbd.keyboard layouts
			gsettings reset org.gnome.libgnomekbd.keyboard options
			gsettings reset org.gnome.libgnomekbd.keyboard model
		fi

		if gsettings list-schemas | grep -qx org.cinnamon.desktop.peripherals.keyboard; then
			gsettings set org.cinnamon.desktop.peripherals.keyboard delay 220
			gsettings set org.cinnamon.desktop.peripherals.keyboard repeat-interval 25
		fi

		if gsettings list-schemas | grep -qx org.cinnamon.desktop.default-applications.terminal; then
			gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
			gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg -e
		fi
	fi

	# The vendor user units may start before Cinnamon exports its display
	# environment. XDG autostart launches the indicator after the graphical
	# session is ready instead.
	systemctl --user mask --now gammastep.service gammastep-indicator.service
}

configure_kde() {
	local writer

	if command -v kwriteconfig6 >/dev/null; then
		writer=kwriteconfig6
	elif command -v kwriteconfig5 >/dev/null; then
		writer=kwriteconfig5
	else
		return
	fi

	"$writer" --file kxkbrc --group Layout --key Use true
	"$writer" --file kxkbrc --group Layout --key ResetOldOptions true
	"$writer" --file kxkbrc --group Layout --key LayoutList "$XKBLAYOUT"
	"$writer" --file kxkbrc --group Layout --key VariantList "$XKBVARIANT"
	"$writer" --file kxkbrc --group Layout --key Options "$XKBOPTIONS"
	"$writer" --file kcminputrc --group Keyboard --key KeyRepeat repeat
	"$writer" --file kcminputrc --group Keyboard --key RepeatDelay 220
	"$writer" --file kcminputrc --group Keyboard --key RepeatRate 40
	"$writer" --file kwinrc --group NightColor --key Active true
	"$writer" --file kwinrc --group NightColor --key Mode DarkLight
	"$writer" --file kwinrc --group NightColor --key DayTemperature 5500
	"$writer" --file kwinrc --group NightColor --key NightTemperature 4500
	"$writer" --file kdeglobals --group General --key TerminalApplication ghostty
	"$writer" --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop
}

case "${XDG_CURRENT_DESKTOP:-}" in
*Cinnamon*) configure_cinnamon ;;
*KDE*) configure_kde ;;
esac

if [ -n "${DISPLAY:-}" ] && command -v setxkbmap >/dev/null; then
	setxkbmap -layout "$XKBLAYOUT" -variant "$XKBVARIANT" \
		-option '' -option "$XKBOPTIONS"
fi
