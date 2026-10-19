#!/usr/bin/env bash

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

mkdir -p \
    "$temp_dir/home/.config/nvim" \
    "$temp_dir/home/.local/bin" \
    "$temp_dir/data/applications" \
    "$temp_dir/config/nvim" \
    "$temp_dir/config/autostart" \
    "$temp_dir/config/systemd/user" \
    "$temp_dir/config/ty"
touch "$temp_dir/home/.local/bin/existing-command"
printf '{"keep":true}\n' >"$temp_dir/config/ty/ty-receipt.json"
ln -s "$repo" "$temp_dir/home/dotfiles"
ln -s "$repo/.profile" "$temp_dir/home/.profile"
ln -s "$repo/xdg/readline" "$temp_dir/config/readline"
ln -s "$repo/xdg/new-tab/new-tab.service" \
    "$temp_dir/config/systemd/user/new-tab.service"
printf 'old unit\n' >"$temp_dir/config/systemd/user/kanata.service"

HOME="$temp_dir/home" XDG_CONFIG_HOME="$temp_dir/config" \
    XDG_DATA_HOME="$temp_dir/data" \
    "$repo/scripts/bootstrap/link-configs.sh" >/dev/null

test "$(readlink "$temp_dir/config/readline")" = "$repo/configs/xdg/readline"
test "$(readlink "$temp_dir/config/fd")" = "$repo/configs/xdg/fd"
test "$(readlink "$temp_dir/config/mpv")" = "$repo/configs/xdg/mpv"
test "$(readlink "$temp_dir/config/fontconfig")" = "$repo/configs/xdg/fontconfig"
test "$(readlink "$temp_dir/config/firefox")" = "$repo/configs/xdg/firefox"
test "$(readlink "$temp_dir/config/gammastep")" = "$repo/configs/xdg/gammastep"
test "$(readlink "$temp_dir/config/autostart/gammastep-indicator.desktop")" = \
    "$repo/configs/xdg/autostart/gammastep-indicator.desktop"
test "$(readlink "$temp_dir/config/new-tab")" = "$repo/configs/xdg/new-tab"
test "$(readlink "$temp_dir/config/kanata")" = "$repo/configs/xdg/kanata"
test "$(readlink "$temp_dir/config/atuin")" = "$repo/configs/xdg/atuin"
test "$(readlink "$temp_dir/config/xm6-audio-guard")" = \
    "$repo/configs/xdg/xm6-audio-guard"
test "$(readlink "$temp_dir/config/mise")" = "$repo/configs/xdg/mise"
test "$(git config --file "$temp_dir/config/git/config" --get core.pager)" = delta
test "$(git config --file "$temp_dir/config/git/config" --get interactive.diffFilter)" = \
    'delta --color-only'
test "$(readlink "$temp_dir/config/wgetrc")" = "$repo/configs/xdg/wgetrc"
test "$(readlink "$temp_dir/config/xdg-terminals.list")" = \
    "$repo/configs/xdg/xdg-terminals.list"
test "$(readlink "$temp_dir/config/X-Cinnamon-xdg-terminals.list")" = \
    "$repo/configs/xdg/X-Cinnamon-xdg-terminals.list"
grep -Fqx 'com.mitchellh.ghostty.desktop' "$temp_dir/config/xdg-terminals.list"
grep -Fqx 'com.mitchellh.ghostty.desktop' \
    "$temp_dir/config/X-Cinnamon-xdg-terminals.list"
grep -Fqx 'hsts-file = ~/.local/state/wget-hsts' "$temp_dir/config/wgetrc"
test "$(readlink "$temp_dir/config/ty/ty.toml")" = "$repo/configs/xdg/ty/ty.toml"
test "$(readlink "$temp_dir/home/.profile")" = "$repo/configs/home/profile"
test "$(readlink "$temp_dir/config/systemd/user/new-tab.service")" = \
    "$repo/configs/xdg/new-tab/new-tab.service"
test "$(readlink "$temp_dir/config/systemd/user/kanata.service")" = \
    "$repo/configs/xdg/kanata/kanata.service"
test "$(readlink "$temp_dir/config/systemd/user/xm6-audio-guard.service")" = \
    "$repo/configs/xdg/xm6-audio-guard/xm6-audio-guard.service"
grep -Fqx 'old unit' "$temp_dir/config/systemd/user/kanata.service-old"
test ! -e "$temp_dir/config/readline-old" && test ! -L "$temp_dir/config/readline-old"
test ! -e "$temp_dir/home/.profile-old" && test ! -L "$temp_dir/home/.profile-old"
grep -Fqx '{"keep":true}' "$temp_dir/config/ty/ty-receipt.json"
test ! -e "$temp_dir/config/ty-old"
test -f "$temp_dir/config/new-tab/blank.html"
test -f "$temp_dir/config/new-tab/background.webp"
test -f "$temp_dir/config/new-tab/new-tab.service"
test -f "$temp_dir/config/kanata/kanata.service"
test -f "$temp_dir/config/xm6-audio-guard/watch.sh"
test -f "$temp_dir/config/xm6-audio-guard/xm6-audio-guard.service"
grep -Fq 'background.webp' "$temp_dir/config/new-tab/blank.html"
grep -Fq 'background-size: cover' "$temp_dir/config/new-tab/blank.html"
grep -Fq 'background-position: right center' "$temp_dir/config/new-tab/blank.html"
grep -Fq 'http.server 8766 --bind 127.0.0.1' "$temp_dir/config/new-tab/new-tab.service"
grep -Fq \
    'ExecStart=%h/.local/share/mise/shims/kanata --cfg %h/.config/kanata/kanata.kbd' \
    "$temp_dir/config/kanata/kanata.service"
grep -Fq 'bluez_output.58_18_62_26_39_3E.' \
    "$temp_dir/config/xm6-audio-guard/watch.sh"
grep -Fq 'set-sink-mute "$sink_id" 1' \
    "$temp_dir/config/xm6-audio-guard/watch.sh"
grep -Fq 'ExecStart=/usr/bin/bash %h/.config/xm6-audio-guard/watch.sh' \
    "$temp_dir/config/xm6-audio-guard/xm6-audio-guard.service"
test "$(readlink "$temp_dir/config/VSCodium/User/settings.json")" = "$repo/configs/xdg/codium/settings.json"
test "$(readlink "$temp_dir/config/VSCodium/User/keybindings.json")" = "$repo/configs/xdg/codium/keybindings.json"
test ! -e "$temp_dir/config/codium"
test -f "$temp_dir/home/.local/bin/existing-command"
test "$(readlink "$temp_dir/home/.local/bin/appgate")" = "$repo/bin/appgate"
test "$(readlink "$temp_dir/home/.local/bin/codium")" = "$repo/bin/codium"
test "$(readlink "$temp_dir/home/.local/bin/fd")" = "$repo/bin/fd"
test "$(readlink "$temp_dir/home/.local/bin/rg")" = "$repo/bin/rg"
test "$(readlink "$temp_dir/home/.local/bin/steam")" = "$repo/bin/steam"
grep -Fqx 'Exec=codium %F' "$temp_dir/data/applications/codium.desktop"
grep -Fqx 'Exec=codium --new-window %F' \
    "$temp_dir/data/applications/codium.desktop"
if grep -Fq '/usr/share/codium/codium' \
    "$temp_dir/data/applications/codium.desktop"; then
    echo 'Codium desktop entry bypasses the fake-home launcher' >&2
    exit 1
fi
"$temp_dir/home/.local/bin/fd" --version | grep -Fq 'fdfind '
test "$(find "$repo/bin" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)" = \
    $'appgate\ncodium\nfd\nfix-xm6-audio\njson-to-env\nrg\nsteam\nsteam-textractor'

appgate_test="$temp_dir/appgate"
mkdir -p "$appgate_test/bin" "$appgate_test/data"
cat >"$appgate_test/bin/real-appgate" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$HOME" "$*"
EOF
chmod +x "$appgate_test/bin/real-appgate"
output="$(XDG_DATA_HOME="$appgate_test/data" \
    APPGATE_BIN="$appgate_test/bin/real-appgate" \
    "$repo/bin/appgate" --url=appgate://example)"
test "$output" = "$appgate_test/data/appgate/home
--url=appgate://example"
test -d "$appgate_test/data/appgate/home"
grep -Fqx 'exec "$appgate_bin" "$@"' \
    "$repo/bin/appgate"

printf 'appgate icon\n' >"$appgate_test/icon.svg"
cat >"$appgate_test/bin/real-kdocker" <<'EOF'
#!/usr/bin/env sh
attempt=0
while [ ! -s "$APPGATE_CLOSE_TO_TRAY_TEST_LOG" ] && [ "$attempt" -lt 100 ]; do
    attempt=$((attempt + 1))
    sleep 0.01
done
printf '%s\n' "$*" >"$KDOCKER_TEST_LOG"
EOF
cat >"$appgate_test/bin/real-xdotool" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' 123456
EOF
cat >"$appgate_test/bin/real-close-to-tray" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$*" >"$APPGATE_CLOSE_TO_TRAY_TEST_LOG"
EOF
chmod +x "$appgate_test/bin/real-kdocker" \
    "$appgate_test/bin/real-xdotool" \
    "$appgate_test/bin/real-close-to-tray"

output="$(APPGATE_BIN="$appgate_test/bin/real-appgate" \
    APPGATE_CLOSE_TO_TRAY_BIN="$appgate_test/bin/real-close-to-tray" \
    APPGATE_CLOSE_TO_TRAY_TEST_LOG="$appgate_test/close-to-tray.log" \
    APPGATE_ICON="$appgate_test/icon.svg" \
    DISPLAY=:99 \
    KDOCKER_BIN="$appgate_test/bin/real-kdocker" \
    KDOCKER_TEST_LOG="$appgate_test/kdocker.log" \
    XDOTOOL_BIN="$appgate_test/bin/real-xdotool" \
    XDG_DATA_HOME="$appgate_test/data" \
    XDG_SESSION_TYPE=x11 \
    "$repo/bin/appgate" --url=appgate://example)"
test "$output" = "$appgate_test/data/appgate/home
--url=appgate://example"
grep -Fqx -- \
    "-m -i $appgate_test/icon.svg -w 0x1e240" \
    "$appgate_test/kdocker.log"
grep -Fqx '0x1e240' "$appgate_test/close-to-tray.log"

output="$(APPGATE_BIN="$appgate_test/bin/real-appgate" \
    APPGATE_ICON="$appgate_test/icon.svg" \
    DISPLAY=:99 \
    KDOCKER_BIN="$appgate_test/bin/real-kdocker" \
    XDG_DATA_HOME="$appgate_test/data" \
    XDG_SESSION_TYPE=wayland \
    "$repo/bin/appgate" --url=appgate://example)"
test "$output" = "$appgate_test/data/appgate/home
--url=appgate://example"

steam_test="$temp_dir/steam"
mkdir -p "$steam_test/data/fixsteam"
cat >"$steam_test/data/fixsteam/steam" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$*" >"$STEAM_TEST_LAUNCH_LOG"
EOF
chmod +x "$steam_test/data/fixsteam/steam"

STEAM_TEST_LAUNCH_LOG="$steam_test/launch.log" \
    XDG_DATA_HOME="$steam_test/data" \
    "$repo/bin/steam" 'argument with spaces' steam://open/games
grep -Fqx 'argument with spaces steam://open/games' "$steam_test/launch.log"

textractor_launcher_test="$temp_dir/steam-textractor"
mkdir -p \
    "$textractor_launcher_test/bin" \
    "$textractor_launcher_test/data/Steam/steamapps/common/Test Game" \
    "$textractor_launcher_test/data/textractor/current/x86"
cat >"$textractor_launcher_test/data/Steam/steamapps/appmanifest_123.acf" <<'EOF'
"AppState"
{
    "appid" "123"
    "installdir" "Test Game"
}
EOF
printf 'fake PE\n' >"$textractor_launcher_test/data/Steam/steamapps/common/Test Game/game.exe"
printf 'fake Textractor\n' >"$textractor_launcher_test/data/textractor/current/x86/Textractor.exe"
cat >"$textractor_launcher_test/bin/file" <<'EOF'
#!/usr/bin/env bash
printf 'PE32 executable (GUI) Intel 80386, for MS Windows\n'
EOF
cat >"$textractor_launcher_test/bin/protontricks-launch" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$TEXTRACTOR_LAUNCH_TEST_LOG"
EOF
cat >"$textractor_launcher_test/bin/game" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$TEXTRACTOR_GAME_TEST_LOG"
EOF
chmod +x "$textractor_launcher_test/bin/"*

SteamAppId=123 \
    TEXTRACTOR_ATTACH_DELAY=0 \
    TEXTRACTOR_GAME_TEST_LOG="$textractor_launcher_test/game.log" \
    TEXTRACTOR_LAUNCH_TEST_LOG="$textractor_launcher_test/launch.log" \
    XDG_DATA_HOME="$textractor_launcher_test/data" \
    PATH="$textractor_launcher_test/bin:$PATH" \
    "$repo/bin/steam-textractor" game \
    "$textractor_launcher_test/data/Steam/steamapps/common/Test Game/game.exe" \
    'argument with spaces'
grep -Fqx \
    "$textractor_launcher_test/data/Steam/steamapps/common/Test Game/game.exe argument with spaces" \
    "$textractor_launcher_test/game.log"
grep -Fqx -- \
    "--no-term --appid 123 $textractor_launcher_test/data/textractor/current/x86/Textractor.exe /pgame.exe" \
    "$textractor_launcher_test/launch.log"
tr -d '\r' <"$textractor_launcher_test/data/textractor/current/x86/SavedGames.txt" |
    grep -Fqx "Z:${textractor_launcher_test//\//\\}\\data\\Steam\\steamapps\\common\\Test Game\\game.exe"
grep -Fqx 'Auto%20attach=true' \
    "$textractor_launcher_test/data/textractor/current/x86/Textractor.ini"

mkdir -p "$temp_dir/search/node_modules"
mkdir -p "$temp_dir/search/venv"
printf 'visible needle\n' >"$temp_dir/search/needle-visible.txt"
printf 'hidden needle\n' >"$temp_dir/search/node_modules/needle-hidden.txt"
printf 'venv needle\n' >"$temp_dir/search/venv/needle-venv.txt"
XDG_CONFIG_HOME="$temp_dir/config" \
    "$temp_dir/home/.local/bin/rg" needle "$temp_dir/search" \
    >"$temp_dir/rg-results"
grep -Fq 'visible needle' "$temp_dir/rg-results"
if grep -Fq 'hidden needle' "$temp_dir/rg-results"; then
    echo 'rg ignored the shared fd ignore file' >&2
    exit 1
fi
if grep -Fq 'venv needle' "$temp_dir/rg-results"; then
    echo 'rg searched the Python virtual environment' >&2
    exit 1
fi

XDG_CONFIG_HOME="$temp_dir/config" \
    fdfind --hidden --no-ignore-vcs needle "$temp_dir/search" \
    >"$temp_dir/fd-results"
grep -Fq 'needle-visible.txt' "$temp_dir/fd-results"
if grep -Fq 'needle-hidden.txt' "$temp_dir/fd-results"; then
    echo 'fd ignored its global ignore file' >&2
    exit 1
fi
if grep -Fq 'needle-venv.txt' "$temp_dir/fd-results"; then
    echo 'fd searched the Python virtual environment' >&2
    exit 1
fi

git -c core.excludesFile="$repo/configs/xdg/git/ignore" \
    -C "$temp_dir/search" init -q
git -c core.excludesFile="$repo/configs/xdg/git/ignore" \
    -C "$temp_dir/search" check-ignore -q venv/needle-venv.txt

HOME="$temp_dir/home" XDG_CONFIG_HOME="$temp_dir/config" \
    XDG_DATA_HOME="$temp_dir/data" \
    "$repo/scripts/bootstrap/link-configs.sh" >/dev/null
test ! -e "$temp_dir/home/.profile-old"

mkdir -p "$temp_dir/collision-home/.config/nvim"
printf 'keep me\n' >"$temp_dir/collision-home/.profile"
printf 'older backup\n' >"$temp_dir/collision-home/.profile-old"

if HOME="$temp_dir/collision-home" XDG_CONFIG_HOME="$temp_dir/collision-home/.config" \
    "$repo/scripts/bootstrap/link-configs.sh" >/dev/null 2>&1; then
    echo "installer overwrote an existing backup" >&2
    exit 1
fi

grep -qx 'keep me' "$temp_dir/collision-home/.profile"
grep -qx 'older backup' "$temp_dir/collision-home/.profile-old"

uninitialized_firefox_home="$temp_dir/uninitialized-firefox-home"
mkdir -p "$uninitialized_firefox_home/.config"
if HOME="$uninitialized_firefox_home" \
    XDG_CONFIG_HOME="$uninitialized_firefox_home/.config" \
    "$repo/scripts/optional/firefox/configure-profile.sh" \
    >"$temp_dir/firefox-no-profile.out" 2>"$temp_dir/firefox-no-profile.err"; then
    echo 'Firefox profile configuration succeeded without a profile' >&2
    exit 1
fi
grep -Fqx \
    'Firefox profile not found. Launch and close Firefox once, then rerun this script.' \
    "$temp_dir/firefox-no-profile.err"

firefox_root="$temp_dir/firefox-home/.config/mozilla/firefox"
mkdir -p \
    "$firefox_root/Profiles/test.default-release/chrome" \
    "$temp_dir/firefox-home/.config"
ln -s "$repo/configs/xdg/firefox" "$temp_dir/firefox-home/.config/firefox"
printf 'old user.js\n' >"$firefox_root/Profiles/test.default-release/user.js"
printf 'old userContent.css\n' \
    >"$firefox_root/Profiles/test.default-release/chrome/userContent.css"
cat >"$firefox_root/profiles.ini" <<'EOF'
[Installtest]
Default=Profiles/test.default-release
Locked=1
EOF

HOME="$temp_dir/firefox-home" \
    XDG_CONFIG_HOME="$temp_dir/firefox-home/.config" \
    "$repo/scripts/optional/firefox/configure-profile.sh" >/dev/null

test "$(readlink "$firefox_root/Profiles/test.default-release/user.js")" = \
    "$repo/configs/xdg/firefox/user.js"
test "$(readlink "$firefox_root/Profiles/test.default-release/chrome/userContent.css")" = \
    "$repo/configs/xdg/firefox/chrome/userContent.css"
grep -qx 'old user.js' "$firefox_root/Profiles/test.default-release/user.js-old"
grep -qx 'old userContent.css' \
    "$firefox_root/Profiles/test.default-release/chrome/userContent.css-old"
grep -Fq 'regexp("^moz-extension://.*/html/newtab[.]html$")' \
    "$firefox_root/Profiles/test.default-release/chrome/userContent.css"
grep -Fq 'background-color: #1c1b22 !important;' \
    "$firefox_root/Profiles/test.default-release/chrome/userContent.css"

ln -sfn "$repo/xdg/firefox/user.js" \
    "$firefox_root/Profiles/test.default-release/user.js"
ln -sfn "$repo/xdg/firefox/chrome/userContent.css" \
    "$firefox_root/Profiles/test.default-release/chrome/userContent.css"

HOME="$temp_dir/firefox-home" \
    XDG_CONFIG_HOME="$temp_dir/firefox-home/.config" \
    "$repo/scripts/optional/firefox/configure-profile.sh" >/dev/null

test "$(readlink "$firefox_root/Profiles/test.default-release/user.js")" = \
    "$repo/configs/xdg/firefox/user.js"
test "$(readlink "$firefox_root/Profiles/test.default-release/chrome/userContent.css")" = \
    "$repo/configs/xdg/firefox/chrome/userContent.css"

legacy_root="$temp_dir/legacy-firefox-home/.mozilla/firefox"
mkdir -p \
    "$legacy_root/Profiles/test.default-release" \
    "$temp_dir/legacy-firefox-home/.config"
ln -s "$repo/configs/xdg/firefox" "$temp_dir/legacy-firefox-home/.config/firefox"
cat >"$legacy_root/profiles.ini" <<'EOF'
[Installtest]
Default=Profiles/test.default-release
Locked=1
EOF

HOME="$temp_dir/legacy-firefox-home" \
    XDG_CONFIG_HOME="$temp_dir/legacy-firefox-home/.config" \
    "$repo/scripts/optional/firefox/configure-profile.sh" >/dev/null

test "$(readlink "$legacy_root/Profiles/test.default-release/user.js")" = \
    "$repo/configs/xdg/firefox/user.js"
test "$(readlink "$legacy_root/Profiles/test.default-release/chrome/userContent.css")" = \
    "$repo/configs/xdg/firefox/chrome/userContent.css"

mkdir -p \
    "$temp_dir/fake-bin" \
    "$temp_dir/setup-home"

cat >"$temp_dir/fake-bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$BOOTSTRAP_LOG"
EOF
chmod +x "$temp_dir/fake-bin/sudo"

cat >"$temp_dir/fake-bin/git" <<'EOF'
#!/usr/bin/env bash
[ -z "${GIT_TEST_LOG:-}" ] || printf '%s\n' "$*" >>"$GIT_TEST_LOG"
if [ "$1" = "-C" ] && [ "$3" = "rev-parse" ] && [ "$4" = "HEAD" ]; then
    cat "$2/.git-head"
    exit
fi
if [ "$1" = "-C" ] && [ "$3" = "checkout" ] && [ "$4" = "--detach" ]; then
    printf '%s\n' "$5" >"$2/.git-head"
    exit
fi
destination="${!#}"
test -d "$(dirname "$destination")"
mkdir "$destination"
case "$destination" in
    */zinit.git) touch "$destination/zinit.zsh" ;;
    */mpvacious)
        mkdir -p "$destination/.git" "$destination/mpvacious"
        printf '%s\n' '5dc199342d8b98a529170aff1d18bbaec904f877' >"$destination/.git-head"
        printf 'return cfg_mgr.query("menu_max_shown_line_length")\n' >"$destination/mpvacious/main.lua"
        printf '{"version": "v26.7.13.0"}' >"$destination/mpvacious/version.json"
        ;;
    */autosubsync-mpv)
        mkdir -p "$destination/.git"
        printf '%s\n' 'a6dc1bbf86d82d001b34c6b223d1f82ee3d7b2cc' >"$destination/.git-head"
        ;;
    */kwin-minimize2tray)
        mkdir -p "$destination/.git"
        printf '%s\n' 'f5e8d140a6660324cafa2188350c858134c80ab2' \
            >"$destination/.git-head"
        ;;
    */checkout)
        if printf '%s\n' "$*" | grep -Fq \
            'https://github.com/kuator/yomichan-forvo-server'; then
            mkdir -p "$destination/.git"
            printf '%s\n' 'e1c167ef6c0c5de8b2144ae5e88ff3b274262f3b' \
                >"$destination/.git-head"
            printf '%s\n' 'fork source' >"$destination/__init__.py"
            cat >"$destination/config.json" <<'CONFIG'
{
  "port": 8770,
  "language": "ja",
  "request_timeout_seconds": 3,
  "lookup_timeout_seconds": 5
}
CONFIG
        fi
        ;;
esac
EOF
chmod +x "$temp_dir/fake-bin/git"

cat >"$temp_dir/fake-bin/cmake" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$CMAKE_TEST_LOG"
if [ "${1:-}" = -B ]; then
    mkdir -p "$2"
fi
EOF
chmod +x "$temp_dir/fake-bin/cmake"

cat >"$temp_dir/fake-bin/curl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$CURL_TEST_LOG"
output=''
source_url=''
while [ "$#" -gt 0 ]; do
    case "$1" in
    --output)
        output="$2"
        shift 2
        ;;
    file://*)
        source_url="$1"
        shift
        ;;
    *) shift ;;
    esac
done
if [ -n "$output" ]; then
    cp "${source_url#file://}" "$output"
    exit 0
fi
cat <<'INSTALLER'
mkdir -p "$(dirname "$MISE_INSTALL_PATH")"
cat >"$MISE_INSTALL_PATH" <<'MISE'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$MISE_TEST_LOG"
if [ "${3:-}" = uv ] && [ "${4:-}" = tool ] && [ "${5:-}" = list ]; then
    if [ -x "$UV_TOOL_BIN_DIR/ffsubsync" ]; then
        printf '%s\n' 'ffsubsync v0.4.31' '- ffsubsync'
    fi
elif [ "${3:-}" = uv ] && [ "${4:-}" = tool ] && [ "${5:-}" = install ]; then
    mkdir -p "$UV_TOOL_BIN_DIR"
    cat >"$UV_TOOL_BIN_DIR/ffsubsync" <<'FFSUBSYNC'
#!/usr/bin/env sh
printf '%s\n' 'ffsubsync 0.4.31'
FFSUBSYNC
    chmod +x "$UV_TOOL_BIN_DIR/ffsubsync"
elif [ "${3:-}" = cargo ] && [ "${4:-}" = install ]; then
    mkdir -p "$CARGO_HOME/bin"
    cat >"$CARGO_HOME/bin/alass-cli" <<'ALASS'
#!/usr/bin/env sh
printf '%s\n' 'alass-cli 2.0.0'
ALASS
    chmod +x "$CARGO_HOME/bin/alass-cli"
fi
MISE
chmod +x "$MISE_INSTALL_PATH"
INSTALLER
EOF
chmod +x "$temp_dir/fake-bin/curl"

cat >"$temp_dir/fake-bin/systemctl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
EOF
chmod +x "$temp_dir/fake-bin/systemctl"

cat >"$temp_dir/fake-bin/gsettings" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = list-schemas ]; then
    printf '%s\n' \
        org.cinnamon.desktop.input-sources \
        org.cinnamon.desktop.default-applications.terminal \
        org.cinnamon.desktop.peripherals.keyboard \
        org.freedesktop.ibus.general \
        org.gnome.libgnomekbd.keyboard
else
    printf '%s\n' "$*" >>"$GSETTINGS_LOG"
fi
EOF
chmod +x "$temp_dir/fake-bin/gsettings"

cat >"$temp_dir/fake-bin/kwriteconfig6" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$KWRITECONFIG_LOG"
EOF
chmod +x "$temp_dir/fake-bin/kwriteconfig6"

cat >"$temp_dir/fake-bin/setxkbmap" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$XKB_TEST_LOG"
EOF
chmod +x "$temp_dir/fake-bin/setxkbmap"

cat >"$temp_dir/fake-bin/protontricks" <<'EOF'
#!/usr/bin/env bash
printf 'protontricks (1.13.1)\n'
EOF
cat >"$temp_dir/fake-bin/fc-cache" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$temp_dir/fake-bin/protontricks" "$temp_dir/fake-bin/fc-cache"

prepare_textractor_fixture() {
    local fixture_home="$1"
    local fixture_release="$fixture_home/.local/share/textractor/releases/260801"
    mkdir -p "$fixture_release/x86" "$fixture_release/x64" \
        "$fixture_home/.local/share/fonts"
    printf 'fake Textractor\n' >"$fixture_release/x86/Textractor.exe"
    printf 'fake Textractor\n' >"$fixture_release/x64/Textractor.exe"
    printf 'fake hook\n' >"$fixture_release/x86/texthook.dll"
    printf 'fake hook\n' >"$fixture_release/x64/texthook.dll"
    printf 'fake font\n' >"$fixture_release/INSTALL_THIS_UNICODE_FONT.ttf"
    printf 'fake font\n' >"$fixture_home/.local/share/fonts/Textractor-Unicode.ttf"
    printf '%s\n' \
        '86346c71ba961e993b8b40419d8720204ccaf8fe20606bbd267eb765ba2ff2ef' \
        >"$fixture_release/.archive-sha256"
}

cat >"$temp_dir/ubuntu-24.04" <<'EOF'
ID=ubuntu
VERSION_ID="24.04"
EOF
cat >"$temp_dir/ubuntu-26.04" <<'EOF'
ID=ubuntu
VERSION_ID="26.04"
EOF

mkdir -p "$temp_dir/cpufreq-supported/policy0"
printf '%s\n' 'default performance balance_performance balance_power power' \
    >"$temp_dir/cpufreq-supported/policy0/energy_performance_available_preferences"
mkdir -p "$temp_dir/cpufreq-unsupported/policy0" \
    "$temp_dir/cpufreq-unsupported/policy1"
printf '%s\n' 'default performance balance_performance balance_power power' \
    >"$temp_dir/cpufreq-unsupported/policy0/energy_performance_available_preferences"

prepare_textractor_fixture "$temp_dir/setup-home"

leetcode_deck_test="$temp_dir/leetcode-deck"
mkdir -p "$leetcode_deck_test/source"
printf 'fixture collection\n' >"$leetcode_deck_test/source/collection.anki2"
(
    cd "$leetcode_deck_test/source"
    zip -q "$leetcode_deck_test/fixture.apkg" collection.anki2
)
leetcode_deck_sha256="$(sha256sum "$leetcode_deck_test/fixture.apkg" | cut -d' ' -f1)"

SYSTEMCTL_LOG="$temp_dir/systemctl.log" \
    HOME="$temp_dir/home" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CONFIG_HOME="$temp_dir/config" \
    "$repo/scripts/optional/firefox/configure-new-tab.sh" >/dev/null

grep -Fqx -- '--user daemon-reload' "$temp_dir/systemctl.log"
grep -qx -- '--user enable --now new-tab.service' "$temp_dir/systemctl.log"

BOOTSTRAP_LOG="$temp_dir/kanata-sudo.log" \
    SYSTEMCTL_LOG="$temp_dir/kanata-systemctl.log" \
    HOME="$temp_dir/home" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CONFIG_HOME="$temp_dir/config" \
    "$repo/scripts/optional/system/configure-kanata.sh" >/dev/null

grep -Fqx -- '--user daemon-reload' "$temp_dir/kanata-systemctl.log"
grep -Fqx -- '--user enable kanata.service' \
    "$temp_dir/kanata-systemctl.log"
grep -Fqx -- '--user restart kanata.service' \
    "$temp_dir/kanata-systemctl.log"

BOOTSTRAP_LOG="$temp_dir/sudo.log" \
    BITWARDEN_INSTALLED_VERSION=2026.7.0 \
    CARGO_HOME="$temp_dir/setup-home/.local/share/cargo" \
    CURL_TEST_LOG="$temp_dir/curl.log" \
    CPUFREQ_ROOT="$temp_dir/cpufreq-supported" \
    GSETTINGS_LOG="$temp_dir/gsettings.log" \
    MISE_TEST_LOG="$temp_dir/mise.log" \
    MPV_SCRIPTS_DIR="$temp_dir/setup-home/mpv-scripts" \
    OS_RELEASE_FILE="$temp_dir/ubuntu-24.04" \
    SYSTEMCTL_LOG="$temp_dir/setup-systemctl.log" \
    XKB_TEST_LOG="$temp_dir/xkb.log" \
    DISPLAY=:99 \
    HOME="$temp_dir/setup-home" \
    LEETCODE_ANKI_DECK_URL="file://$leetcode_deck_test/fixture.apkg" \
    LEETCODE_ANKI_SHA256="$leetcode_deck_sha256" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CURRENT_DESKTOP=X-Cinnamon \
    XDG_CONFIG_HOME="$temp_dir/setup-home/.config" \
    XDG_DATA_HOME="$temp_dir/setup-home/.local/share" \
    UV_TOOL_BIN_DIR="$temp_dir/setup-home/.local/bin" \
    UV_TOOL_DIR="$temp_dir/setup-home/.local/share/uv/tools" \
    "$repo/scripts/setup.sh" >/dev/null

grep -qx 'apt-get update' "$temp_dir/sudo.log"
grep -q '^apt-get install -y ' "$temp_dir/sudo.log"
grep -Eq '^apt-get install -y .*git-lfs' "$temp_dir/sudo.log"
grep -Eq '^apt-get install -y .*software-properties-common' "$temp_dir/sudo.log"
grep -Eq '^apt-get install -y .*kdocker' "$temp_dir/sudo.log"
grep -Eq '^apt-get install -y .*gammastep' "$temp_dir/sudo.log"
grep -Eq '^apt-get install -y .*xdotool' "$temp_dir/sudo.log"
grep -Fqx -- '--fail --silent --show-error --location https://mise.run' \
    "$temp_dir/curl.log"
grep -Fqx \
    'install --yes rust uv ty bat eza delta bottom lazygit lazydocker shfmt k9s github:zk-org/zk github:ewhauser/shuck bob github:jtroo/kanata' \
    "$temp_dir/mise.log"
grep -Fqx 'exec -- bob use nightly' "$temp_dir/mise.log"
grep -Fqx 'exec -- uv tool list' "$temp_dir/mise.log"
grep -Fqx 'exec -- uv tool install --force ffsubsync==0.4.31' \
    "$temp_dir/mise.log"
grep -Fqx 'exec -- cargo install --locked --version 2.0.0 alass-cli' \
    "$temp_dir/mise.log"
test "$("$temp_dir/setup-home/.local/bin/ffsubsync" --version)" = \
    'ffsubsync 0.4.31'
test "$("$temp_dir/setup-home/.local/bin/alass" --version)" = \
    'alass-cli 2.0.0'
test "$(cat "$temp_dir/setup-home/mpv-scripts/autosubsync-mpv/.git-head")" = \
    'a6dc1bbf86d82d001b34c6b223d1f82ee3d7b2cc'
if grep -q 'pipewire-audio-client-libraries' "$temp_dir/sudo.log"; then
    echo "default bootstrap would replace the existing audio stack" >&2
    exit 1
fi
test "$(readlink "$temp_dir/setup-home/.profile")" = "$repo/configs/home/profile"
test ! -L "$temp_dir/setup-home/.xprofile"
grep -Fqx 'reset org.gnome.libgnomekbd.keyboard layouts' \
    "$temp_dir/gsettings.log"
grep -Fqx 'reset org.gnome.libgnomekbd.keyboard options' \
    "$temp_dir/gsettings.log"
grep -Fqx 'reset org.gnome.libgnomekbd.keyboard model' \
    "$temp_dir/gsettings.log"
grep -Fqx 'reset org.cinnamon.desktop.input-sources sources' \
    "$temp_dir/gsettings.log"
grep -Fqx 'reset org.cinnamon.desktop.input-sources xkb-options' \
    "$temp_dir/gsettings.log"
grep -Fqx 'set org.cinnamon.desktop.peripherals.keyboard delay 220' \
    "$temp_dir/gsettings.log"
grep -Fqx 'set org.cinnamon.desktop.peripherals.keyboard repeat-interval 25' \
    "$temp_dir/gsettings.log"
grep -Fqx 'set org.cinnamon.desktop.default-applications.terminal exec ghostty' \
    "$temp_dir/gsettings.log"
grep -Fqx 'set org.cinnamon.desktop.default-applications.terminal exec-arg -e' \
    "$temp_dir/gsettings.log"
grep -Fqx 'set org.freedesktop.ibus.general use-system-keyboard-layout true' \
    "$temp_dir/gsettings.log"
grep -Fqx -- \
    '--user mask --now gammastep.service gammastep-indicator.service' \
    "$temp_dir/setup-systemctl.log"
grep -Fqx 'Exec=gammastep-indicator' \
    "$repo/configs/xdg/autostart/gammastep-indicator.desktop"
grep -Fqx 'temp-day=5500' "$repo/configs/xdg/gammastep/config.ini"
grep -Fqx 'temp-night=4500' "$repo/configs/xdg/gammastep/config.ini"
test -f "$repo/configs/system/keyboard"
grep -Fqx 'XKBMODEL="pc105"' "$repo/configs/system/keyboard"
grep -Fqx 'XKBLAYOUT="en,ru"' "$repo/configs/system/keyboard"
grep -Fqx 'XKBVARIANT=","' "$repo/configs/system/keyboard"
grep -Fqx 'XKBOPTIONS="grp:alt_shift_toggle"' "$repo/configs/system/keyboard"
grep -Fqx \
    "install -m 644 $repo/configs/system/xkb/symbols/en /usr/share/X11/xkb/symbols/en" \
    "$temp_dir/sudo.log"
grep -Fqx "install -m 644 $repo/configs/system/keyboard /etc/default/keyboard" \
    "$temp_dir/sudo.log"
grep -Fqx \
    "install -m 644 $repo/configs/system/tmpfiles.d/cpu-energy-preference.conf /etc/tmpfiles.d/cpu-energy-preference.conf" \
    "$temp_dir/sudo.log"
grep -Fqx \
    'systemd-tmpfiles --create /etc/tmpfiles.d/cpu-energy-preference.conf' \
    "$temp_dir/sudo.log"
grep -Fqx \
    'w- /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_performance' \
    "$repo/configs/system/tmpfiles.d/cpu-energy-preference.conf"
grep -Fqx -- '-layout en,ru -variant , -option  -option grp:alt_shift_toggle' \
    "$temp_dir/xkb.log"

mkdir -p "$temp_dir/setup-kde-home"
prepare_textractor_fixture "$temp_dir/setup-kde-home"
BOOTSTRAP_LOG="$temp_dir/kde-setup-sudo.log" \
    BITWARDEN_INSTALLED_VERSION=2026.7.0 \
    CARGO_HOME="$temp_dir/setup-kde-home/.local/share/cargo" \
    CMAKE_TEST_LOG="$temp_dir/kde-setup-cmake.log" \
    CURL_TEST_LOG="$temp_dir/kde-setup-curl.log" \
    GIT_TEST_LOG="$temp_dir/kde-setup-git.log" \
    GHOSTTY_INSTALLED_VERSION='1.3.0-1' \
    KWRITECONFIG_LOG="$temp_dir/kde-setup-kwriteconfig.log" \
    MISE_TEST_LOG="$temp_dir/kde-setup-mise.log" \
    MPV_SCRIPTS_DIR="$temp_dir/setup-kde-home/mpv-scripts" \
    OS_RELEASE_FILE="$temp_dir/ubuntu-26.04" \
    DISPLAY= \
    HOME="$temp_dir/setup-kde-home" \
    LEETCODE_ANKI_DECK_URL="file://$leetcode_deck_test/fixture.apkg" \
    LEETCODE_ANKI_SHA256="$leetcode_deck_sha256" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CURRENT_DESKTOP=KDE \
    XDG_CONFIG_HOME="$temp_dir/setup-kde-home/.config" \
    XDG_DATA_HOME="$temp_dir/setup-kde-home/.local/share" \
    UV_TOOL_BIN_DIR="$temp_dir/setup-kde-home/.local/bin" \
    UV_TOOL_DIR="$temp_dir/setup-kde-home/.local/share/uv/tools" \
    "$repo/scripts/setup.sh" >/dev/null
grep -Fqx -- '--file kxkbrc --group Layout --key LayoutList en,ru' \
    "$temp_dir/kde-setup-kwriteconfig.log"
grep -Eq '^apt-get install -y .*libncurses-dev' \
    "$temp_dir/kde-setup-sudo.log"
grep -Fqx 'apt-get install -y --allow-downgrades ghostty' \
    "$temp_dir/kde-setup-sudo.log"
if grep -Fq 'ghostty-ubuntu-nightly' "$temp_dir/kde-setup-sudo.log"; then
    echo 'Default Kubuntu setup enabled the optional Ghostty nightly channel' >&2
    exit 1
fi
for package in \
    cmake \
    extra-cmake-modules \
    libkf6package-dev \
    libkf6service-dev \
    libkf6statusnotifieritem-dev \
    qt6-declarative-dev; do
    grep -Eq "^apt-get install -y .*$package" \
        "$temp_dir/kde-setup-sudo.log"
done
if grep -Eq '^apt-get install -y .*kdocker' \
    "$temp_dir/kde-setup-sudo.log"; then
    echo 'Kubuntu setup requested the X11-only KDocker package' >&2
    exit 1
fi
if grep -Eq '^apt-get install -y .*gammastep|^apt-get install -y .*redshift' \
    "$temp_dir/kde-setup-sudo.log"; then
    echo 'Kubuntu setup requested an external color-temperature daemon' >&2
    exit 1
fi
grep -Fq \
    'clone --no-checkout https://github.com/luisbocanegra/kwin-minimize2tray.git' \
    "$temp_dir/kde-setup-git.log"
grep -Fq \
    'checkout --detach f5e8d140a6660324cafa2188350c858134c80ab2' \
    "$temp_dir/kde-setup-git.log"
grep -Fq -- '-DBUILD_PLUGIN=OFF' "$temp_dir/kde-setup-cmake.log"
grep -Fq -- '-DINSTALL_SCRIPT=OFF' "$temp_dir/kde-setup-cmake.log"
grep -Fq 'cmake --install ' "$temp_dir/kde-setup-sudo.log"
grep -Fqx 'f5e8d140a6660324cafa2188350c858134c80ab2' \
    "$temp_dir/setup-kde-home/.local/share/dotfiles/kwin-minimize2tray.commit"
if grep -Eq '^apt-get install -y .*libncursesw5-dev' \
    "$temp_dir/kde-setup-sudo.log"; then
    echo 'Kubuntu setup requested removed libncursesw5-dev' >&2
    exit 1
fi

mkdir -p "$temp_dir/unsupported-home"
: >"$temp_dir/unsupported-sudo.log"
if BOOTSTRAP_LOG="$temp_dir/unsupported-sudo.log" \
    CURL_TEST_LOG="$temp_dir/unsupported-curl.log" \
    GSETTINGS_LOG="$temp_dir/unsupported-gsettings.log" \
    MISE_TEST_LOG="$temp_dir/unsupported-mise.log" \
    OS_RELEASE_FILE="$temp_dir/ubuntu-26.04" \
    XKB_TEST_LOG="$temp_dir/unsupported-xkb.log" \
    DISPLAY=:99 \
    HOME="$temp_dir/unsupported-home" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CURRENT_DESKTOP=X-Cinnamon \
    XDG_CONFIG_HOME="$temp_dir/unsupported-home/.config" \
    XDG_DATA_HOME="$temp_dir/unsupported-home/.local/share" \
    "$repo/scripts/setup.sh" >/dev/null 2>&1; then
    echo 'Bootstrap accepted Ubuntu 26.04 with Cinnamon' >&2
    exit 1
fi
test ! -s "$temp_dir/unsupported-sudo.log"
test ! -e "$temp_dir/unsupported-home/.profile"

KWRITECONFIG_LOG="$temp_dir/kwriteconfig.log" \
    BOOTSTRAP_LOG="$temp_dir/kde-sudo.log" \
    DISPLAY= \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CURRENT_DESKTOP=KDE \
    "$repo/scripts/bootstrap/configure-desktop.sh"

for expected in \
    '--file kxkbrc --group Layout --key Use true' \
    '--file kxkbrc --group Layout --key ResetOldOptions true' \
    '--file kxkbrc --group Layout --key LayoutList en,ru' \
    '--file kxkbrc --group Layout --key VariantList ,' \
    '--file kxkbrc --group Layout --key Options grp:alt_shift_toggle' \
    '--file kcminputrc --group Keyboard --key KeyRepeat repeat' \
    '--file kcminputrc --group Keyboard --key RepeatDelay 220' \
    '--file kcminputrc --group Keyboard --key RepeatRate 40' \
    '--file kwinrc --group NightColor --key Active true' \
    '--file kwinrc --group NightColor --key Mode DarkLight' \
    '--file kwinrc --group NightColor --key DayTemperature 5500' \
    '--file kwinrc --group NightColor --key NightTemperature 4500' \
    '--file kdeglobals --group General --key TerminalApplication ghostty' \
    '--file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop'; do
    grep -Fqx -- "$expected" "$temp_dir/kwriteconfig.log"
done

grep -A6 '^(deflayer default' "$repo/configs/xdg/kanata/kanata.kbd" |
    grep -Fqx '    grv'
grep -Fqx '    linux-x11-repeat-delay-rate 220,40' \
    "$repo/configs/xdg/kanata/kanata.kbd"
test "$(grep -Fc '((or (input real lalt) (input real ralt)))' \
    "$repo/configs/xdg/kanata/kanata.kbd")" -eq 2
if rg -q 'rapid-event-delay|@grave|grave \(switch' \
    "$repo/configs/xdg/kanata/kanata.kbd"; then
    echo 'Kanata still contains a global event delay or layout-sensitive grave mapping' >&2
    exit 1
fi

keyboard_repo="$temp_dir/keyboard-repo"
mkdir -p "$keyboard_repo/scripts/bootstrap" "$keyboard_repo/configs/system"
cp "$repo/scripts/bootstrap/configure-desktop.sh" \
    "$keyboard_repo/scripts/bootstrap/configure-desktop.sh"
cat >"$keyboard_repo/configs/system/keyboard" <<'EOF'
XKBMODEL="pc105"
XKBLAYOUT="us,ru,de"
XKBVARIANT=",,"
XKBOPTIONS="grp:alt_shift_toggle"
BACKSPACE="guess"
EOF
KWRITECONFIG_LOG="$temp_dir/custom-keyboard.log" \
    BOOTSTRAP_LOG="$temp_dir/custom-keyboard-sudo.log" \
    DISPLAY= \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CURRENT_DESKTOP=KDE \
    "$keyboard_repo/scripts/bootstrap/configure-desktop.sh"
grep -Fqx -- '--file kxkbrc --group Layout --key LayoutList us,ru,de' \
    "$temp_dir/custom-keyboard.log"
grep -Fqx -- '--file kxkbrc --group Layout --key VariantList ,,' \
    "$temp_dir/custom-keyboard.log"

KWRITECONFIG_LOG="$temp_dir/unknown-kwriteconfig.log" \
    BOOTSTRAP_LOG="$temp_dir/unknown-sudo.log" \
    CPUFREQ_ROOT="$temp_dir/cpufreq-unsupported" \
    DISPLAY= \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CURRENT_DESKTOP=sway \
    "$repo/scripts/bootstrap/configure-desktop.sh"
test ! -e "$temp_dir/unknown-kwriteconfig.log"
grep -Fqx \
    "install -m 644 $repo/configs/system/tmpfiles.d/cpu-energy-preference.conf /etc/tmpfiles.d/cpu-energy-preference.conf" \
    "$temp_dir/unknown-sudo.log"
if grep -Fq 'systemd-tmpfiles --create' "$temp_dir/unknown-sudo.log"; then
    echo 'Unsupported CPU attempted to apply balance_performance' >&2
    exit 1
fi

cat >"$temp_dir/fake-bin/dpkg-divert" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = --truename ]; then
    printf '%s\n' "$2"
fi
EOF
chmod +x "$temp_dir/fake-bin/dpkg-divert"

BOOTSTRAP_LOG="$temp_dir/appgate-system.log" \
    PATH="$temp_dir/fake-bin:$PATH" \
    "$repo/scripts/optional/system/configure-appgate-xdg.sh"
grep -Fqx \
    'dpkg-divert --quiet --local --add --rename --divert /usr/bin/appgate.vendor /usr/bin/appgate' \
    "$temp_dir/appgate-system.log"
grep -Fqx \
    "install -m 755 $repo/bin/appgate /usr/bin/appgate" \
    "$temp_dir/appgate-system.log"

appgate_install_test="$temp_dir/appgate-install"
mkdir -p "$appgate_install_test/bin"
cat >"$appgate_install_test/bin/dpkg-query" <<'EOF'
#!/usr/bin/env bash
if [ -f "$APPGATE_TEST_STATE" ]; then
    cat "$APPGATE_TEST_STATE"
    exit 0
fi
exit 1
EOF
cat >"$appgate_install_test/bin/curl" <<'EOF'
#!/usr/bin/env bash
while [ "$#" -gt 0 ]; do
    if [ "$1" = --output ]; then
        printf 'fake deb\n' >"$2"
        exit 0
    fi
    shift
done
exit 1
EOF
cat >"$appgate_install_test/bin/sha256sum" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
EOF
cat >"$appgate_install_test/bin/dpkg-deb" <<'EOF'
#!/usr/bin/env bash
case "$3" in
Package) printf 'appgate\n' ;;
Version) printf '6.5.3+41284+release\n' ;;
Architecture) printf 'amd64\n' ;;
*) exit 1 ;;
esac
EOF
cat >"$appgate_install_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
cat >"$appgate_install_test/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$APPGATE_TEST_APT_LOG"
printf '6.5.3+41284+release\n' >"$APPGATE_TEST_STATE"
EOF
chmod +x "$appgate_install_test/bin/"*

APPGATE_TEST_APT_LOG="$appgate_install_test/apt.log" \
    APPGATE_TEST_STATE="$appgate_install_test/installed-version" \
    DEB_ARCHITECTURE=amd64 \
    PATH="$appgate_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-appgate.sh" >/dev/null
grep -Eq '^install -y .*/appgate-sdp_6\.5\.3_amd64\.deb$' \
    "$appgate_install_test/apt.log"
test "$(cat "$appgate_install_test/installed-version")" = \
    '6.5.3+41284+release'

appgate_skip_output="$(
    APPGATE_TEST_APT_LOG="$appgate_install_test/apt.log" \
        APPGATE_TEST_STATE="$appgate_install_test/installed-version" \
        DEB_ARCHITECTURE=amd64 \
        PATH="$appgate_install_test/bin:$PATH" \
        "$repo/scripts/bootstrap/install-appgate.sh"
)"
test "$appgate_skip_output" = \
    'Appgate 6.5.3+41284+release already installed.'
test "$(wc -l <"$appgate_install_test/apt.log")" -eq 1

printf '6.6.0+newer\n' >"$appgate_install_test/installed-version"
if APPGATE_TEST_APT_LOG="$appgate_install_test/apt.log" \
    APPGATE_TEST_STATE="$appgate_install_test/installed-version" \
    DEB_ARCHITECTURE=amd64 \
    PATH="$appgate_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-appgate.sh" >/dev/null 2>&1; then
    echo 'Appgate installer replaced an unexpected installed version' >&2
    exit 1
fi
test "$(wc -l <"$appgate_install_test/apt.log")" -eq 1

teams_install_test="$temp_dir/teams-for-linux-install"
mkdir -p "$teams_install_test/bin"
cat >"$teams_install_test/bin/dpkg-query" <<'EOF'
#!/usr/bin/env bash
if [ -f "$TEAMS_FOR_LINUX_TEST_STATE" ]; then
    cat "$TEAMS_FOR_LINUX_TEST_STATE"
    exit 0
fi
exit 1
EOF
cat >"$teams_install_test/bin/curl" <<'EOF'
#!/usr/bin/env bash
while [ "$#" -gt 0 ]; do
    if [ "$1" = --output ]; then
        printf 'fake deb\n' >"$2"
        exit 0
    fi
    shift
done
exit 1
EOF
cat >"$teams_install_test/bin/sha256sum" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
EOF
cat >"$teams_install_test/bin/dpkg-deb" <<'EOF'
#!/usr/bin/env bash
case "$3" in
Package) printf 'teams-for-linux\n' ;;
Version) printf '2.8.0\n' ;;
Architecture) printf 'amd64\n' ;;
*) exit 1 ;;
esac
EOF
cat >"$teams_install_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
cat >"$teams_install_test/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEAMS_FOR_LINUX_TEST_APT_LOG"
printf '2.8.0\n' >"$TEAMS_FOR_LINUX_TEST_STATE"
EOF
chmod +x "$teams_install_test/bin/"*

TEAMS_FOR_LINUX_TEST_APT_LOG="$teams_install_test/apt.log" \
    TEAMS_FOR_LINUX_TEST_STATE="$teams_install_test/installed-version" \
    DEB_ARCHITECTURE=amd64 \
    PATH="$teams_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-teams-for-linux.sh" >/dev/null
grep -Eq '^install -y .*/teams-for-linux_2\.8\.0_amd64\.deb$' \
    "$teams_install_test/apt.log"
test "$(cat "$teams_install_test/installed-version")" = '2.8.0'

teams_skip_output="$(
    TEAMS_FOR_LINUX_TEST_APT_LOG="$teams_install_test/apt.log" \
        TEAMS_FOR_LINUX_TEST_STATE="$teams_install_test/installed-version" \
        DEB_ARCHITECTURE=amd64 \
        PATH="$teams_install_test/bin:$PATH" \
        "$repo/scripts/bootstrap/install-teams-for-linux.sh"
)"
test "$teams_skip_output" = 'Teams-for-Linux 2.8.0 already installed.'
test "$(wc -l <"$teams_install_test/apt.log")" -eq 1

printf '2.9.0\n' >"$teams_install_test/installed-version"
if TEAMS_FOR_LINUX_TEST_APT_LOG="$teams_install_test/apt.log" \
    TEAMS_FOR_LINUX_TEST_STATE="$teams_install_test/installed-version" \
    DEB_ARCHITECTURE=amd64 \
    PATH="$teams_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-teams-for-linux.sh" >/dev/null 2>&1; then
    echo 'Teams-for-Linux installer replaced the deliberate pin' >&2
    exit 1
fi
test "$(wc -l <"$teams_install_test/apt.log")" -eq 1

installed_leetcode_deck="$temp_dir/setup-home/.local/share/leetcode-anki/LeetcodeSuperSet600.apkg"
cmp "$leetcode_deck_test/fixture.apkg" "$installed_leetcode_deck"
leetcode_deck_skip_output="$(
    XDG_DATA_HOME="$temp_dir/setup-home/.local/share" \
        LEETCODE_ANKI_DECK_URL="file://$leetcode_deck_test/fixture.apkg" \
        LEETCODE_ANKI_SHA256="$leetcode_deck_sha256" \
        "$repo/scripts/bootstrap/install-leetcode-anki.sh"
)"
test "$leetcode_deck_skip_output" = 'LeetCode Superset deck already installed.'
if XDG_DATA_HOME="$leetcode_deck_test/bad-data" \
    LEETCODE_ANKI_DECK_URL="file://$leetcode_deck_test/fixture.apkg" \
    LEETCODE_ANKI_SHA256="$(printf '0%.0s' {1..64})" \
    "$repo/scripts/bootstrap/install-leetcode-anki.sh" >/dev/null 2>&1; then
    echo 'LeetCode deck installer accepted an invalid checksum' >&2
    exit 1
fi

ghostty_install_test="$temp_dir/ghostty-install"
mkdir -p "$ghostty_install_test/bin"
cat >"$ghostty_install_test/os-24.04" <<'EOF'
ID=ubuntu
VERSION_ID=24.04
EOF
cat >"$ghostty_install_test/os-26.04" <<'EOF'
ID=ubuntu
VERSION_ID=26.04
EOF
cat >"$ghostty_install_test/bin/dpkg-query" <<'EOF'
#!/usr/bin/env bash
if [ -f "$GHOSTTY_TEST_STATE" ]; then
    cat "$GHOSTTY_TEST_STATE"
    exit 0
fi
exit 1
EOF
cat >"$ghostty_install_test/bin/dpkg" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = --compare-versions ]; then
    [ "$2" = "$4" ] || [ "$2" = 1.3.1-0~ppa1 ]
    exit
fi
exit 1
EOF
cat >"$ghostty_install_test/bin/curl" <<'EOF'
#!/usr/bin/env bash
while [ "$#" -gt 0 ]; do
    if [ "$1" = --output ]; then
        printf 'fake deb\n' >"$2"
        exit 0
    fi
    shift
done
exit 1
EOF
cat >"$ghostty_install_test/bin/sha256sum" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
EOF
cat >"$ghostty_install_test/bin/dpkg-deb" <<'EOF'
#!/usr/bin/env bash
case "$3" in
Package) printf 'ghostty\n' ;;
Version) printf '1.3.1-0~ppa1\n' ;;
Architecture) printf 'amd64\n' ;;
*) exit 1 ;;
esac
EOF
cat >"$ghostty_install_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
cat >"$ghostty_install_test/bin/add-apt-repository" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$GHOSTTY_TEST_REPOSITORY_LOG"
case " $* " in
*" --remove "*) rm -f "$APT_SOURCES_DIR/ghostty-nightly.sources" ;;
*)
    printf 'URIs: https://ppa.launchpadcontent.net/mkasberg/ghostty-ubuntu-nightly/ubuntu\n' \
        >"$APT_SOURCES_DIR/ghostty-nightly.sources"
    ;;
esac
EOF
cat >"$ghostty_install_test/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$GHOSTTY_TEST_APT_LOG"
case "$*" in
*ghostty_1.3.1-0.ppa1_amd64_24.04.deb*)
    printf '1.3.1-0~ppa1\n' >"$GHOSTTY_TEST_STATE"
    ;;
"install -y ghostty")
    printf '1.3.2+nightly20260722T0416~ppa2-resolute1\n' \
        >"$GHOSTTY_TEST_STATE"
    ;;
"install -y --allow-downgrades ghostty")
    printf '1.3.0-1\n' >"$GHOSTTY_TEST_STATE"
    ;;
"update")
    ;;
*) exit 1 ;;
esac
EOF
chmod +x "$ghostty_install_test/bin/"*

GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
    GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
    DEB_ARCHITECTURE=amd64 \
    OS_RELEASE_FILE="$ghostty_install_test/os-24.04" \
    PATH="$ghostty_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-ghostty.sh" >/dev/null
grep -Eq '^install -y .*/ghostty_1\.3\.1-0\.ppa1_amd64_24\.04\.deb$' \
    "$ghostty_install_test/apt.log"
test "$(cat "$ghostty_install_test/installed-version")" = '1.3.1-0~ppa1'

ghostty_skip_output="$(
    GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
        GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
        DEB_ARCHITECTURE=amd64 \
        OS_RELEASE_FILE="$ghostty_install_test/os-24.04" \
        PATH="$ghostty_install_test/bin:$PATH" \
        "$repo/scripts/bootstrap/install-ghostty.sh"
)"
test "$ghostty_skip_output" = 'Ghostty 1.3.1-0~ppa1 already installed.'
test "$(wc -l <"$ghostty_install_test/apt.log")" -eq 1

rm "$ghostty_install_test/installed-version"
mkdir "$ghostty_install_test/sources"
GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
    GHOSTTY_TEST_REPOSITORY_LOG="$ghostty_install_test/repository.log" \
    GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
    APT_SOURCES_DIR="$ghostty_install_test/sources" \
    DEB_ARCHITECTURE=amd64 \
    OS_RELEASE_FILE="$ghostty_install_test/os-26.04" \
    PATH="$ghostty_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-ghostty.sh" >/dev/null
test ! -e "$ghostty_install_test/repository.log"
grep -Fqx 'update' "$ghostty_install_test/apt.log"
grep -Fqx 'install -y --allow-downgrades ghostty' \
    "$ghostty_install_test/apt.log"
test "$(cat "$ghostty_install_test/installed-version")" = '1.3.0-1'

GHOSTTY_CHANNEL=nightly \
    GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
    GHOSTTY_TEST_REPOSITORY_LOG="$ghostty_install_test/repository.log" \
    GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
    APT_SOURCES_DIR="$ghostty_install_test/sources" \
    DEB_ARCHITECTURE=amd64 \
    OS_RELEASE_FILE="$ghostty_install_test/os-26.04" \
    PATH="$ghostty_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-ghostty.sh" >/dev/null
grep -Fqx -- \
    '--yes --no-update ppa:mkasberg/ghostty-ubuntu-nightly' \
    "$ghostty_install_test/repository.log"
grep -Fqx 'update' "$ghostty_install_test/apt.log"
grep -Fqx 'install -y ghostty' "$ghostty_install_test/apt.log"
case "$(cat "$ghostty_install_test/installed-version")" in
*+nightly*) ;;
*) exit 1 ;;
esac

GHOSTTY_CHANNEL=nightly \
    GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
    GHOSTTY_TEST_REPOSITORY_LOG="$ghostty_install_test/repository.log" \
    GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
    APT_SOURCES_DIR="$ghostty_install_test/sources" \
    DEB_ARCHITECTURE=amd64 \
    OS_RELEASE_FILE="$ghostty_install_test/os-26.04" \
    PATH="$ghostty_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-ghostty.sh" >/dev/null
test "$(wc -l <"$ghostty_install_test/repository.log")" -eq 1
test "$(grep -Fxc 'update' "$ghostty_install_test/apt.log")" -eq 3
test "$(grep -Fxc 'install -y ghostty' "$ghostty_install_test/apt.log")" -eq 2

GHOSTTY_CHANNEL=stable \
    GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
    GHOSTTY_TEST_REPOSITORY_LOG="$ghostty_install_test/repository.log" \
    GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
    APT_SOURCES_DIR="$ghostty_install_test/sources" \
    DEB_ARCHITECTURE=amd64 \
    OS_RELEASE_FILE="$ghostty_install_test/os-26.04" \
    PATH="$ghostty_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-ghostty.sh" >/dev/null
grep -Fqx -- \
    '--yes --no-update --remove ppa:mkasberg/ghostty-ubuntu-nightly' \
    "$ghostty_install_test/repository.log"
test ! -e "$ghostty_install_test/sources/ghostty-nightly.sources"
test "$(cat "$ghostty_install_test/installed-version")" = '1.3.0-1'

if GHOSTTY_CHANNEL=nightly \
    GHOSTTY_TEST_APT_LOG="$ghostty_install_test/apt.log" \
    GHOSTTY_TEST_REPOSITORY_LOG="$ghostty_install_test/repository.log" \
    GHOSTTY_TEST_STATE="$ghostty_install_test/installed-version" \
    DEB_ARCHITECTURE=amd64 \
    OS_RELEASE_FILE="$ghostty_install_test/os-24.04" \
    PATH="$ghostty_install_test/bin:$PATH" \
    "$repo/scripts/bootstrap/install-ghostty.sh" >/dev/null 2>&1; then
    echo 'Ghostty nightly unexpectedly succeeded on Ubuntu 24.04' >&2
    exit 1
fi

ncalayer_test="$temp_dir/ncalayer-install"
mkdir -p \
    "$ncalayer_test/bin" \
    "$ncalayer_test/home/.config/NCALayer" \
    "$ncalayer_test/home/.local/share" \
    "$ncalayer_test/payload/additions/cert" \
    "$ncalayer_test/payload/additions/jre8_ncalayer/bin"
printf 'preserve module state\n' \
    >"$ncalayer_test/home/.config/NCALayer/module-state"
printf 'fake icon\n' >"$ncalayer_test/payload/additions/ncalayer.png"
printf 'fake root certificate\n' \
    >"$ncalayer_test/payload/additions/cert/root_rsa.cer"
printf 'fake NCA certificate\n' \
    >"$ncalayer_test/payload/additions/cert/nca_rsa.cer"
cat >"$ncalayer_test/payload/additions/jre8_ncalayer/bin/java" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat >"$ncalayer_test/payload/ncalayer.sh" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = --version ]; then
    printf '  Версия    = 1.4 \n'
    exit 1
fi
if [ "${1:-}" != --nogui ]; then
    exit 1
fi
read -r install_parent
if [ "$install_parent" = I ]; then
    read -r install_parent
fi
install_dir="$install_parent/NCALayer"
mkdir -p "$install_dir" "$XDG_DATA_HOME/applications"
cp "$0" "$install_dir/ncalayer.sh"
chmod +x "$install_dir/ncalayer.sh"
cp -a additions/jre8_ncalayer "$install_dir/"
printf '[Desktop Entry]\nExec="%s/ncalayer.sh" --run\n' "$install_dir" \
    >"$XDG_DATA_HOME/applications/ncalayer.desktop"
exit 1
EOF
chmod +x \
    "$ncalayer_test/payload/ncalayer.sh" \
    "$ncalayer_test/payload/additions/jre8_ncalayer/bin/java"
(cd "$ncalayer_test/payload" && zip -qr "$ncalayer_test/ncalayer.zip" .)
ncalayer_sha1="$(sha1sum "$ncalayer_test/ncalayer.zip" | awk '{print $1}')"
ncalayer_sha256="$(sha256sum "$ncalayer_test/ncalayer.zip" | awk '{print $1}')"
cat >"$ncalayer_test/bin/pgrep" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
cat >"$ncalayer_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
exec "$@"
EOF
cat >"$ncalayer_test/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$NCALAYER_TEST_APT_LOG"
EOF
chmod +x "$ncalayer_test/bin/"*

ncalayer_output="$(
    HOME="$ncalayer_test/home" \
        NCALAYER_ARCHIVE="$ncalayer_test/ncalayer.zip" \
        NCALAYER_PUBLISHED_SHA1="$ncalayer_sha1" \
        NCALAYER_SHA256="$ncalayer_sha256" \
        NCALAYER_TEST_APT_LOG="$ncalayer_test/apt.log" \
        PATH="$ncalayer_test/bin:$PATH" \
        XDG_CONFIG_HOME="$ncalayer_test/home/.config" \
        XDG_DATA_HOME="$ncalayer_test/home/.local/share" \
        "$repo/scripts/optional/desktop/install-ncalayer.sh"
)"
printf '%s\n' "$ncalayer_output" | grep -Fqx \
    "Installed NCALayer 1.4 in $ncalayer_test/home/.local/share/NCALayer."
grep -Fqx \
    'install -y libnotify-bin libnss3-tools pcsc-tools xdg-utils xxd' \
    "$ncalayer_test/apt.log"
grep -Fqx 'preserve module state' \
    "$ncalayer_test/home/.config/NCALayer/module-state"
test -x "$ncalayer_test/home/.local/share/NCALayer/ncalayer.sh"
test -x "$ncalayer_test/home/.local/share/NCALayer/jre8_ncalayer/bin/java"
test "$(cat "$ncalayer_test/home/.local/share/NCALayer/.dotfiles-archive-sha256")" = \
    "$ncalayer_sha256"

ncalayer_skip_output="$(
    HOME="$ncalayer_test/home" \
        NCALAYER_ARCHIVE="$ncalayer_test/ncalayer.zip" \
        NCALAYER_PUBLISHED_SHA1="$ncalayer_sha1" \
        NCALAYER_SHA256="$ncalayer_sha256" \
        NCALAYER_TEST_APT_LOG="$ncalayer_test/apt.log" \
        PATH="$ncalayer_test/bin:$PATH" \
        XDG_CONFIG_HOME="$ncalayer_test/home/.config" \
        XDG_DATA_HOME="$ncalayer_test/home/.local/share" \
        "$repo/scripts/optional/desktop/install-ncalayer.sh"
)"
test "$ncalayer_skip_output" = \
    'NCALayer 1.4 already installed from the pinned archive.'
test "$(wc -l <"$ncalayer_test/apt.log")" -eq 1

sudo_test="$temp_dir/sudo-provider"
mkdir -p "$sudo_test/bin"
cat >"$sudo_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = --version ]; then
    printf '%s\n' "$SUDO_TEST_VERSION"
    exit
fi
printf '%s\n' "$*" >>"$SUDO_TEST_LOG"
if [ "${1:-}" = tee ]; then
    cat >"$2"
fi
EOF
chmod +x "$sudo_test/bin/sudo"

: >"$sudo_test/sudo-rs.log"
sudo_rs_output="$(
    BASHRC_FILE="$sudo_test/sudo-rs-bashrc" \
        PATH="$sudo_test/bin:$PATH" \
        SUDO_ADMIN_FLAG_FILE="$sudo_test/sudo-rs-admin-flag" \
        SUDO_TEST_LOG="$sudo_test/sudo-rs.log" \
        SUDO_TEST_VERSION='sudo-rs 0.2.13' \
        "$repo/scripts/optional/system/disable-sudo-admin-flag.sh"
)"
test "$sudo_rs_output" = \
    'sudo-rs does not create ~/.sudo_as_admin_successful; nothing to configure.'
test ! -s "$sudo_test/sudo-rs.log"
test ! -e "$sudo_test/sudo-rs-admin-flag"

printf 'sudo_as_admin_successful\n' >"$sudo_test/classic-bashrc"
: >"$sudo_test/classic.log"
BASHRC_FILE="$sudo_test/classic-bashrc" \
    PATH="$sudo_test/bin:$PATH" \
    SUDO_ADMIN_FLAG_FILE="$sudo_test/classic-admin-flag" \
    SUDO_TEST_LOG="$sudo_test/classic.log" \
    SUDO_TEST_VERSION='Sudo version 1.9.15p5' \
    "$repo/scripts/optional/system/disable-sudo-admin-flag.sh" >/dev/null
grep -Fqx 'tee '"$sudo_test/classic-admin-flag" "$sudo_test/classic.log"
grep -Fqx 'Defaults !admin_flag' "$sudo_test/classic-admin-flag"

expected_scripts=(
    scripts/bootstrap/configure-desktop.sh
    scripts/bootstrap/install-appgate.sh
    scripts/bootstrap/install-mise.sh
    scripts/bootstrap/install-packages.sh
    scripts/bootstrap/install-bitwarden.sh
    scripts/bootstrap/install-ghostty.sh
    scripts/bootstrap/install-leetcode-anki.sh
    scripts/bootstrap/install-teams-for-linux.sh
    scripts/bootstrap/install-textractor.sh
    scripts/bootstrap/install-subtitle-sync.sh
    scripts/bootstrap/install-window-tray.sh
    scripts/bootstrap/link-configs.sh
    scripts/optional/desktop/import-gnome-terminal-profile.sh
    scripts/optional/desktop/install-ncalayer.sh
    scripts/optional/desktop/install-steam.sh
    scripts/optional/desktop/install-ubuntu-mono-nerd-font.sh
    scripts/optional/desktop/lightdm/configure-xauthority.sh
    scripts/optional/desktop/lightdm/patch-binary.sh
    scripts/optional/firefox/configure-profile.sh
    scripts/optional/firefox/configure-new-tab.sh
    scripts/optional/firefox/install.sh
    scripts/optional/firefox/patch-keybindings.sh
    scripts/optional/japanese/download-yomitan-audio.sh
    scripts/optional/japanese/download-yomitan-dictionaries.sh
    scripts/optional/japanese/setup.sh
    scripts/optional/japanese/update-japanese-sentences.sh
    scripts/optional/shell/configure-bash-xdg.sh
    scripts/optional/shell/install-codex.sh
    scripts/optional/shell/set-default-zsh.sh
    scripts/optional/system/configure-kanata.sh
    scripts/optional/system/configure-appgate-xdg.sh
    scripts/optional/system/configure-ssh-xdg.sh
    scripts/optional/system/disable-snap.sh
    scripts/optional/system/disable-sudo-admin-flag.sh
)
grep -Fqx 'BITWARDEN_VERSION="2026.7.0"' \
    "$repo/scripts/bootstrap/install-bitwarden.sh"
grep -Fqx 'APPGATE_VERSION="6.5.3+41284+release"' \
    "$repo/scripts/bootstrap/install-appgate.sh"
grep -Fqx 'APPGATE_SHA256="3320b6f1c3933bd129bc7be5356b5d3516eecb0974b810fc1b9f9c0020733116"' \
    "$repo/scripts/bootstrap/install-appgate.sh"
grep -Fqx '"$scripts_dir/bootstrap/install-appgate.sh"' \
    "$repo/scripts/setup.sh"
grep -Fqx '"$scripts_dir/bootstrap/install-bitwarden.sh"' \
    "$repo/scripts/setup.sh"
grep -Fqx 'GHOSTTY_UBUNTU_2404_VERSION="1.3.1-0~ppa1"' \
    "$repo/scripts/bootstrap/install-ghostty.sh"
grep -Fqx 'GHOSTTY_UBUNTU_2404_SHA256="c838f69c6a047eb9d648f9d68502db783102e981d965a3a6ce416e1c07bdbacd"' \
    "$repo/scripts/bootstrap/install-ghostty.sh"
grep -Fqx 'GHOSTTY_NIGHTLY_PPA="ppa:mkasberg/ghostty-ubuntu-nightly"' \
    "$repo/scripts/bootstrap/install-ghostty.sh"
grep -Fqx 'ghostty_channel="${GHOSTTY_CHANNEL:-stable}"' \
    "$repo/scripts/bootstrap/install-ghostty.sh"
grep -Fqx '"$scripts_dir/bootstrap/install-ghostty.sh"' \
    "$repo/scripts/setup.sh"
grep -Fqx 'LEETCODE_ANKI_COMMIT="aeabd4dd10c5163ef84f8390c4f8a5c8812a9ceb"' \
    "$repo/scripts/bootstrap/install-leetcode-anki.sh"
grep -Fqx 'LEETCODE_ANKI_SHA256="${LEETCODE_ANKI_SHA256:-c3f83153bea080c75230b825d741d8ad00aae6092100a04fbbebf37d60d96e9b}"' \
    "$repo/scripts/bootstrap/install-leetcode-anki.sh"
grep -Fqx '"$scripts_dir/bootstrap/install-leetcode-anki.sh"' \
    "$repo/scripts/setup.sh"
grep -Fq '.nightMode .card pre' "$repo/configs/anki/leetcode.css"
grep -Fq 'max-width: 960px' "$repo/configs/anki/leetcode.css"
grep -Fq 'updateModelStyling' "$repo/scripts/bootstrap/install-leetcode-anki.sh"
grep -Fqx 'NCALAYER_VERSION="1.4"' \
    "$repo/scripts/optional/desktop/install-ncalayer.sh"
grep -Fqx 'NCALAYER_SHA256="${NCALAYER_SHA256:-31f47c126fe56107d76f11c446110dfa09fc397f032a54ef8ee4d7bcaf6461cb}"' \
    "$repo/scripts/optional/desktop/install-ncalayer.sh"
grep -Fqx 'TEAMS_FOR_LINUX_VERSION="2.8.0"' \
    "$repo/scripts/bootstrap/install-teams-for-linux.sh"
grep -Fqx 'TEAMS_FOR_LINUX_SHA256="c3fafdc32f1d0fff5b40c47c06457e7edfb9c7936a7ce35ed9cf7824dab6c89f"' \
    "$repo/scripts/bootstrap/install-teams-for-linux.sh"
grep -Fqx '"$scripts_dir/bootstrap/install-teams-for-linux.sh"' \
    "$repo/scripts/setup.sh"
grep -Fqx 'TEXTRACTOR_VERSION="260801"' \
    "$repo/scripts/bootstrap/install-textractor.sh"
grep -Fqx 'TEXTRACTOR_SHA256="86346c71ba961e993b8b40419d8720204ccaf8fe20606bbd267eb765ba2ff2ef"' \
    "$repo/scripts/bootstrap/install-textractor.sh"
grep -Fqx '"$scripts_dir/bootstrap/install-textractor.sh"' \
    "$repo/scripts/setup.sh"
for script in "${expected_scripts[@]}"; do
    test -x "$repo/$script"
    case "$script" in
        scripts/optional/*)
            grep -Fq "\`${script#scripts/optional/}\`" "$repo/README.md"
            ;;
    esac
done

for heading in \
    '## Fresh-machine runbook' \
    '## Repository map' \
    '### Configurations and study resources' \
    '### Automatic bootstrap' \
    '### Manual setup' \
    '### Wrapper' \
    '### Test' \
    '### Downloaded/vendor content'; do
    grep -Fqx "$heading" "$repo/README.md"
done
grep -Fq './tests/bootstrap.sh' "$repo/README.md"

profile_home="$temp_dir/profile-home"
mkdir -p "$profile_home"
profile_compinit="$(
    env -u skip_global_compinit HOME="$profile_home" sh -c \
        '. "$1"; printf "%s" "$skip_global_compinit"' \
        sh "$repo/configs/home/profile"
)"
test "$profile_compinit" = 1

codex_test="$temp_dir/codex-home"
codex_release=0.146.0-x86_64-unknown-linux-musl
codex_release_dir="$codex_test/home/.codex/packages/standalone/releases/$codex_release"
mkdir -p \
    "$codex_release_dir/bin" \
    "$codex_test/home/.local/bin" \
    "$codex_test/data" \
    "$codex_test/bin"
printf 'model = "test"\n' >"$codex_test/home/.codex/config.toml"
printf '#!/bin/sh\n' >"$codex_release_dir/bin/codex"
chmod +x "$codex_release_dir/bin/codex"
ln -s "$codex_release_dir" \
    "$codex_test/home/.codex/packages/standalone/current"
ln -s "$codex_test/home/.codex/packages/standalone/current/bin/codex" \
    "$codex_test/home/.local/bin/codex"
cat >"$codex_test/bin/pgrep" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
cat >"$codex_test/home/.local/bin/mise" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$CODEX_HOME" >"$CODEX_TEST_HOME_LOG"
printf '%s\n' "$*" >>"$CODEX_TEST_MISE_LOG"
EOF
chmod +x "$codex_test/bin/pgrep" "$codex_test/home/.local/bin/mise"

HOME="$codex_test/home" \
    CODEX_TEST_HOME_LOG="$codex_test/codex-home.log" \
    CODEX_TEST_MISE_LOG="$codex_test/mise.log" \
    XDG_DATA_HOME="$codex_test/data" \
    PATH="$codex_test/bin:$PATH" \
    "$repo/scripts/optional/shell/install-codex.sh" >/dev/null
test ! -e "$codex_test/home/.codex"
grep -Fqx 'model = "test"' "$codex_test/data/codex/config.toml"
test ! -L "$codex_test/home/.local/bin/codex"
grep -Fqx "$codex_test/data/codex" "$codex_test/codex-home.log"
grep -Fqx 'exec -- npm install --global @openai/codex@latest' "$codex_test/mise.log"
grep -Fqx 'exec -- npm install --global @agentclientprotocol/codex-acp@latest' "$codex_test/mise.log"
grep -Fqx 'reshim' "$codex_test/mise.log"

mkdir -p "$codex_test/home/.codex"
printf 'preserve source\n' >"$codex_test/home/.codex/source"
if HOME="$codex_test/home" XDG_DATA_HOME="$codex_test/data" \
    PATH="$codex_test/bin:$PATH" \
    "$repo/scripts/optional/shell/install-codex.sh" >/dev/null 2>&1; then
    echo 'Codex installation overwrote an existing destination' >&2
    exit 1
fi
grep -qx 'preserve source' "$codex_test/home/.codex/source"

codex_active_test="$temp_dir/codex-active"
mkdir -p "$codex_active_test/home/.codex" "$codex_active_test/data" "$codex_active_test/bin"
printf 'still active\n' >"$codex_active_test/home/.codex/config.toml"
cat >"$codex_active_test/bin/pgrep" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$codex_active_test/bin/pgrep"
if HOME="$codex_active_test/home" XDG_DATA_HOME="$codex_active_test/data" \
    PATH="$codex_active_test/bin:$PATH" \
    "$repo/scripts/optional/shell/install-codex.sh" >/dev/null 2>&1; then
    echo 'Codex installation ran while Codex was active' >&2
    exit 1
fi
grep -qx 'still active' "$codex_active_test/home/.codex/config.toml"

ssh_test="$temp_dir/ssh-xdg"
mkdir -p "$ssh_test/home/.config/ssh" "$ssh_test/home/.ssh" "$ssh_test/bin"
cat >"$ssh_test/home/.config/ssh/config" <<'EOF'
Host *
    IdentityFile ~/.config/ssh/id_rsa
    UserKnownHostsFile ~/.config/ssh/known_hosts
EOF
printf 'existing\nshared\n' >"$ssh_test/home/.config/ssh/known_hosts"
printf 'shared\nnew\n' >"$ssh_test/home/.ssh/known_hosts"
printf 'obsolete\n' >"$ssh_test/home/.ssh/known_hosts.old"
cat >"$ssh_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = tee ]; then
    cat >"$SSH_TEST_SYSTEM_CONFIG"
    exit
fi
exec "$@"
EOF
cat >"$ssh_test/bin/ssh" <<'EOF'
#!/usr/bin/env bash
printf 'userknownhostsfile %s/.config/ssh/known_hosts\n' "$HOME"
EOF
chmod +x "$ssh_test/bin/sudo" "$ssh_test/bin/ssh"

HOME="$ssh_test/home" \
    PATH="$ssh_test/bin:$PATH" \
    SSH_TEST_SYSTEM_CONFIG="$ssh_test/system.conf" \
    XDG_CONFIG_HOME="$ssh_test/home/.config" \
    "$repo/scripts/optional/system/configure-ssh-xdg.sh" >/dev/null
grep -Fqx "Include \"$ssh_test/home/.config/ssh/config\"" "$ssh_test/system.conf"
test "$(sort "$ssh_test/home/.config/ssh/known_hosts")" = $'existing\nnew\nshared'
test ! -e "$ssh_test/home/.ssh"

test -f "$repo/configs/gnome-terminal/profile.dconf"
grep -Fq "\"\$dotfiles/configs/gnome-terminal/profile.dconf\"" \
    "$repo/scripts/optional/desktop/import-gnome-terminal-profile.sh"

if SNAP_BLOCK_FILE="$temp_dir/missing-no-snap.pref" \
    "$repo/scripts/optional/firefox/install.sh" \
    >"$temp_dir/firefox-install.out" 2>"$temp_dir/firefox-install.err"; then
    echo 'Firefox installation succeeded before Snap was disabled' >&2
    exit 1
fi
grep -Fqx \
    'Snap is not disabled. Run scripts/optional/system/disable-snap.sh first.' \
    "$temp_dir/firefox-install.err"

firefox_install_test="$temp_dir/firefox-install"
mkdir -p "$firefox_install_test/bin"
touch "$firefox_install_test/no-snap.pref"
cat >"$firefox_install_test/bin/dpkg-query" <<'EOF'
#!/usr/bin/env bash
printf 'install ok installed'
EOF
cat >"$firefox_install_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$FIREFOX_INSTALL_LOG"
if [ "${1:-}" = tee ]; then
    cat >/dev/null
fi
EOF
chmod +x "$firefox_install_test/bin/dpkg-query" "$firefox_install_test/bin/sudo"
FIREFOX_ARCHIVE="$firefox_install_test/missing-omni.ja" \
    FIREFOX_INSTALL_LOG="$firefox_install_test/commands" \
    SNAP_BLOCK_FILE="$firefox_install_test/no-snap.pref" \
    PATH="$firefox_install_test/bin:$PATH" \
    "$repo/scripts/optional/firefox/install.sh" >/dev/null
grep -Fqx 'apt install -y firefox' "$firefox_install_test/commands"

firefox_patch_test="$temp_dir/firefox-patch"
mkdir -p "$firefox_patch_test/bin" "$firefox_patch_test/home"
cat >"$firefox_patch_test/bin/unzip" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
chmod +x "$firefox_patch_test/bin/unzip"
if FIREFOX_ARCHIVE="$firefox_patch_test/missing-omni.ja" \
    HOME="$firefox_patch_test/home" \
    PATH="$firefox_patch_test/bin:$PATH" \
    "$repo/scripts/optional/firefox/patch-keybindings.sh" \
    >"$firefox_patch_test/out" 2>"$firefox_patch_test/err"; then
    echo 'Firefox keybinding patch succeeded without Firefox' >&2
    exit 1
fi
grep -Fqx \
    "Firefox installation not found at $firefox_patch_test/missing-omni.ja. Run scripts/optional/firefox/install.sh first." \
    "$firefox_patch_test/err"

lightdm_test="$temp_dir/lightdm"
mkdir -p "$lightdm_test/bin"
cat >"$lightdm_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
cat >"$lightdm_test/bin/strings" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
chmod +x "$lightdm_test/bin/sudo" "$lightdm_test/bin/strings"
for script in configure-xauthority.sh patch-binary.sh; do
    if LIGHTDM_BIN="$lightdm_test/missing-lightdm" \
        PATH="$lightdm_test/bin:$PATH" \
        "$repo/scripts/optional/desktop/lightdm/$script" \
        >"$lightdm_test/$script.out" 2>"$lightdm_test/$script.err"; then
        echo "$script succeeded without LightDM" >&2
        exit 1
    fi
    grep -Fqx \
        'LightDM is not installed. Run this script only on Ubuntu Cinnamon with LightDM.' \
        "$lightdm_test/$script.err"
done

gnome_terminal_test="$temp_dir/gnome-terminal"
mkdir -p "$gnome_terminal_test/bin"
for command in dconf gsettings; do
    cat >"$gnome_terminal_test/bin/$command" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
    chmod +x "$gnome_terminal_test/bin/$command"
done
if DCONF_BIN="$gnome_terminal_test/missing-dconf" \
    GSETTINGS_BIN="$gnome_terminal_test/missing-gsettings" \
    PATH="$gnome_terminal_test/bin:$PATH" \
    "$repo/scripts/optional/desktop/import-gnome-terminal-profile.sh" \
    >"$gnome_terminal_test/out" 2>"$gnome_terminal_test/err"; then
    echo 'GNOME Terminal profile import succeeded without GNOME Terminal' >&2
    exit 1
fi
grep -Fqx \
    'GNOME Terminal is not installed. Run this script only on Ubuntu Cinnamon with GNOME Terminal.' \
    "$gnome_terminal_test/err"

mkdir -p "$temp_dir/no-zsh-bin"
if PATH="$temp_dir/no-zsh-bin" SHELL=/usr/bin/zsh \
    "$repo/scripts/optional/shell/set-default-zsh.sh" \
    >"$temp_dir/no-zsh.out" 2>"$temp_dir/no-zsh.err"; then
    echo 'Default-shell configuration succeeded without Zsh' >&2
    exit 1
fi
grep -Fqx 'Zsh is not installed. Run scripts/setup.sh first.' \
    "$temp_dir/no-zsh.err"

snap_test="$temp_dir/snap-test"
mkdir -p "$snap_test/bin" "$snap_test/home/snap/firefox" "$snap_test/trash"
printf 'keep me\n' >"$snap_test/home/snap/firefox/data"
cat >"$snap_test/bin/snap" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = list ]; then
    cat <<'SNAPS'
Name        Version  Rev  Tracking       Publisher   Notes
SNAPS
    cat "$SNAP_TEST_STATE"
fi
EOF
chmod +x "$snap_test/bin/snap"
cat >"$snap_test/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$SNAP_TEST_LOG"
if [ "${1:-}" = snap ] && [ "${2:-}" = remove ]; then
    name="${4:-}"
    if [ "$name" = gtk-common-themes ] && grep -q '^snap-store ' "$SNAP_TEST_STATE"; then
        exit 1
    fi
    awk -v name="$name" '$1 != name' "$SNAP_TEST_STATE" >"$SNAP_TEST_STATE.tmp"
    mv "$SNAP_TEST_STATE.tmp" "$SNAP_TEST_STATE"
    if [ -e "$HOME/snap/$name" ]; then
        mv "$HOME/snap/$name" "$SNAP_TEST_TRASH/"
    fi
fi
if [ "${1:-}" = tee ]; then
    cat >"$SNAP_TEST_PIN"
fi
EOF
chmod +x "$snap_test/bin/sudo"
cat >"$snap_test/state" <<'EOF'
firefox           1  1  latest/stable  canonical  -
gtk-common-themes 1  1  latest/stable  canonical  -
snap-store        1  1  latest/stable  canonical  -
spotify           1  1  latest/stable  spotify    classic
core24            1  1  latest/stable  canonical  base
snapd             1  1  latest/stable  canonical  snapd
EOF

SNAP_TEST_LOG="$snap_test/commands" \
    SNAP_TEST_PIN="$snap_test/pin" \
    SNAP_TEST_STATE="$snap_test/state" \
    SNAP_TEST_TRASH="$snap_test/trash" \
    HOME="$snap_test/home" \
    PATH="$snap_test/bin:$PATH" \
    "$repo/scripts/optional/system/disable-snap.sh" >/dev/null

grep -qx 'snap remove --purge firefox' "$snap_test/commands"
grep -qx 'snap remove --purge spotify' "$snap_test/commands"
test "$(grep -c '^snap remove --purge gtk-common-themes$' "$snap_test/commands")" -eq 2
grep -qx 'snap remove --purge core24' "$snap_test/commands"
grep -qx 'snap remove --purge snapd' "$snap_test/commands"
grep -qx 'apt-get purge -y snapd' "$snap_test/commands"
grep -qx 'Package: snapd' "$snap_test/pin"
grep -qx 'Pin-Priority: -10' "$snap_test/pin"
grep -qx 'keep me' "$snap_test/home/snap/firefox/data"

study_home="$temp_dir/study-home"
mkdir -p \
    "$study_home/opt/anki" \
    "$study_home/Downloads" \
    "$study_home/.config/mpv/scripts" \
    "$study_home/.local/share/Anki2/addons21/580654285" \
    "$study_home/.local/share/Anki2/addons21/2055492159"
printf '26.08\n' >"$study_home/opt/anki/.version"
cat >"$study_home/.local/share/Anki2/addons21/580654285/config.json" <<'EOF'
{
  "port": 9999,
  "language": "zh"
}
EOF
cat >"$study_home/.local/share/Anki2/addons21/580654285/meta.json" <<'EOF'
{
  "name": "Yomichan Forvo Server",
  "disabled": false,
  "update_enabled": true
}
EOF

grep -Fqx 'VERSION="26.08"' "$repo/scripts/optional/japanese/setup.sh"
grep -Fqx 'ANKI_RELEASE="anki-linux"' "$repo/scripts/optional/japanese/setup.sh"
# shellcheck disable=SC2016 # Match the literal VERSION reference.
grep -Fqx 'ANKI_ARCHIVE="anki-${VERSION}-linux-x86_64.tar.zst"' \
    "$repo/scripts/optional/japanese/setup.sh"

study_output="$(
    GIT_TEST_LOG="$study_home/git.log" \
        HOME="$study_home" \
        PATH="$temp_dir/fake-bin:$PATH" \
        XDG_CONFIG_HOME="$study_home/.config" \
        XDG_DATA_HOME="$study_home/.local/share" \
        "$repo/scripts/optional/japanese/setup.sh"
)"

GIT_TEST_LOG="$study_home/git.log" \
    HOME="$study_home" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CONFIG_HOME="$study_home/.config" \
    XDG_DATA_HOME="$study_home/.local/share" \
    "$repo/scripts/optional/japanese/setup.sh" >/dev/null

grep -q -- 'clone --depth 1 --branch dotfiles-2026-08-09-v2 https://github.com/kuator/mpvacious' \
    "$study_home/git.log"
test "$(grep -Fc 'clone --depth 1 --branch dotfiles-2026-08-09-v2' "$study_home/git.log")" -eq 1
grep -q -- 'clone --depth 1 --branch dotfiles-2026-08-15-forvo-timeout https://github.com/kuator/yomichan-forvo-server' \
    "$study_home/git.log"
test "$(grep -Fc 'clone --depth 1 --branch dotfiles-2026-08-15-forvo-timeout' "$study_home/git.log")" -eq 1
grep -Fq -- '-C '"$study_home/.config/mpv/scripts/mpvacious"' rev-parse HEAD' \
    "$study_home/git.log"
grep -Fq -- '-C '"$study_home/.local/share/Anki2/addons21/580654285"' rev-parse HEAD' \
    "$study_home/git.log"
grep -Fqx 'menu_max_shown_line_length=200' \
    "$repo/configs/xdg/mpv/script-opts/subs2srs.conf"
grep -Fqx '{"version": "v26.7.28.0"}' \
    "$study_home/.config/mpv/scripts/mpvacious/mpvacious/version.json"

missing_addons="$(printf '%s\n' "$study_output" | sed -n 's/^Missing AnkiWeb add-ons: //p')"
printf '%s\n' "$missing_addons" | grep -qw 1045800357
if printf '%s\n' "$missing_addons" | grep -qw 2055492159; then
    echo 'already installed Anki add-on was reported missing' >&2
    exit 1
fi
printf '%s\n' "$study_output" | grep -Fq \
    'Run download-yomitan-audio.sh after installing add-on 1045800357.'
test "$(jq -r '.port' "$study_home/.local/share/Anki2/addons21/580654285/config.json")" -eq 9999
test "$(jq -r '.language' "$study_home/.local/share/Anki2/addons21/580654285/config.json")" = zh
test "$(jq -r '.request_timeout_seconds' "$study_home/.local/share/Anki2/addons21/580654285/config.json")" -eq 3
test "$(jq -r '.lookup_timeout_seconds' "$study_home/.local/share/Anki2/addons21/580654285/config.json")" -eq 5
test "$(jq -r '.name' "$study_home/.local/share/Anki2/addons21/580654285/meta.json")" = \
    'Yomichan Forvo Server (kuator fork)'
test "$(jq -r '.update_enabled' "$study_home/.local/share/Anki2/addons21/580654285/meta.json")" = false
grep -Fqx 'fork source' \
    "$study_home/.local/share/Anki2/addons21/580654285/__init__.py"

audio_test="$temp_dir/audio-test"
mkdir -p \
    "$audio_test/Anki2/addons21/1045800357" \
    "$audio_test/cache" \
    "$audio_test/fixture/user_files/forvo_files" \
    "$audio_test/fixture/user_files/jpod_files" \
    "$audio_test/fixture/user_files/nhk16_files" \
    "$audio_test/fixture/user_files/shinmeikai8_files"
printf 'audio fixture\n' \
    >"$audio_test/fixture/user_files/nhk16_files/entry.opus"
printf '{}\n' >"$audio_test/fixture/user_files/jmdict_forms.json"
tar -cJf "$audio_test/fixture.tar.xz" \
    -C "$audio_test/fixture" user_files

cat >"$temp_dir/fake-bin/aria2c" <<'EOF'
#!/usr/bin/env bash
for argument in "$@"; do
    case "$argument" in
        --dir=*) destination="${argument#--dir=}" ;;
    esac
done
printf 'download\n' >>"$AUDIO_TEST_LOG"
cp "$AUDIO_TEST_ARCHIVE" \
    "$destination/local-yomichan-audio-collection-2023-06-11-opus.tar.xz"
EOF
chmod +x "$temp_dir/fake-bin/aria2c"

AUDIO_TEST_ARCHIVE="$audio_test/fixture.tar.xz" \
    AUDIO_TEST_LOG="$audio_test/aria2.log" \
    HOME="$audio_test/home" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CACHE_HOME="$audio_test/cache" \
    XDG_DATA_HOME="$audio_test" \
    "$repo/scripts/optional/japanese/download-yomitan-audio.sh" >/dev/null

test -f "$audio_test/Anki2/addons21/1045800357/user_files/nhk16_files/entry.opus"
test -f "$audio_test/cache/dotfiles/yomitan-audio/local-yomichan-audio-collection-2023-06-11-opus.tar.xz"

AUDIO_TEST_ARCHIVE="$audio_test/fixture.tar.xz" \
    AUDIO_TEST_LOG="$audio_test/aria2.log" \
    HOME="$audio_test/home" \
    PATH="$temp_dir/fake-bin:$PATH" \
    XDG_CACHE_HOME="$audio_test/cache" \
    XDG_DATA_HOME="$audio_test" \
    "$repo/scripts/optional/japanese/download-yomitan-audio.sh" >/dev/null
test "$(wc -l <"$audio_test/aria2.log")" -eq 1

test -f "$repo/japanese/anki/addons.txt"
grep -Eq '^1344485230[[:space:]]+AJT Japanese$' "$repo/japanese/anki/addons.txt"
if grep -Eq '^580654285[[:space:]]' "$repo/japanese/anki/addons.txt"; then
    echo 'the pinned Forvo fork should not be listed as an AnkiWeb add-on' >&2
    exit 1
fi
awk 'NF < 2 || $1 !~ /^[0-9]+$/ { exit 1 }' "$repo/japanese/anki/addons.txt" || {
    echo 'japanese/anki/addons.txt must contain a numeric code and name on each line' >&2
    exit 1
}
if rg -q 'Ajatt-Tools/Japanese' "$repo/scripts/optional/japanese/setup.sh"; then
    echo 'AJT Japanese should be installed from the AnkiWeb manifest' >&2
    exit 1
fi

dictionary_count=0
while IFS=$'\t' read -r source filename; do
    [ -n "$source" ] || continue
    case "$source" in \#*) continue ;; esac

    dictionary_count=$((dictionary_count + 1))
    dictionary="japanese/yomitan/dictionaries/$filename"
    test -f "$repo/$dictionary"
    test "$(stat -c %s "$repo/$dictionary")" -lt 100000000
    if git -C "$repo" check-ignore -q -- "$dictionary"; then
        echo "Tracked Yomitan dictionary is ignored: $dictionary" >&2
        exit 1
    fi
done <"$repo/japanese/yomitan/dictionaries.txt"
test "$dictionary_count" -eq 8

grep -qx 'snapshot_quality=40' "$repo/configs/xdg/mpv/script-opts/subs2srs.conf"
grep -qx 'secondary_sub_lang=ru,rus,eng,en,jp,jpn,ja' "$repo/configs/xdg/mpv/script-opts/subs2srs.conf"
grep -qx 'card_overwrite_safeguard=1' "$repo/configs/xdg/mpv/script-opts/subs2srs.conf"
grep -Fqx 'bookmark_save_keybind=["alt+b", "alt+B"]' \
    "$repo/configs/xdg/mpv/script-opts/SimpleBookmark.conf"

"$repo/tests/update-japanese-sentences.sh"
"$repo/tests/python-environment.sh"
"$repo/tests/xm6-audio-guard.sh"

test ! -e "$repo/configs/xdg/zsh/.zshenv"
test ! -e "$repo/configs/xdg/zsh/.zprofile"
test ! -e "$repo/configs/xdg/zsh/.zcompdump"
test ! -e "$repo/xdg"
test ! -e "$repo/desktop"
test ! -e "$repo/.profile"
grep -Fqx 'HISTFILE="$XDG_STATE_HOME/zsh/history"' "$repo/configs/xdg/zsh/.zshrc"
grep -Fqx '  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r --disable-ai)"' \
    "$repo/configs/xdg/zsh/.zshrc"
grep -Fqx 'secrets_filter = true' "$repo/configs/xdg/atuin/config.toml"
grep -Fqx 'add-zsh-hook zshaddhistory _reject_sensitive_history' \
    "$repo/configs/xdg/zsh/.zshrc"
grep -Fqx 'ZINIT[ZCOMPDUMP_PATH]="$XDG_CACHE_HOME/zsh/zcompdump"' \
    "$repo/configs/xdg/zsh/.zshrc"
grep -Fqx 'export PATH="$XDG_DATA_HOME/mise/shims:$PATH"' "$repo/configs/home/profile"
grep -Fqx 'export PATH="$XDG_DATA_HOME/bob/nvim-bin:$PATH"' "$repo/configs/home/profile"
grep -Fqx 'export REDISCLI_HISTFILE="$XDG_STATE_HOME/redis/history"' "$repo/configs/home/profile"
grep -Fqx 'export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/history"' "$repo/configs/home/profile"
grep -Fqx 'export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"' "$repo/configs/home/profile"
grep -Fqx 'export CODEX_HOME="$XDG_DATA_HOME/codex"' "$repo/configs/home/profile"
grep -Fqx 'export NLTK_DATA="$XDG_DATA_HOME/nltk"' "$repo/configs/home/profile"
grep -Fqx 'export KUBECACHEDIR="$XDG_CACHE_HOME/kube"' "$repo/configs/home/profile"
test "$(grep '^export PATH=' "$repo/configs/home/profile" | tail -n 1)" = \
    'export PATH="$XDG_DATA_HOME/mise/shims:$PATH"'
grep -Fqx '(( $+commands[mise] )) && eval "$(mise activate zsh)"' \
    "$repo/configs/xdg/zsh/.zshrc"
if rg -q 'alias ssh=|SSH_CONFIG|sshCommand' \
    "$repo/configs/home/profile" "$repo/configs/xdg/zsh/.zshrc" "$repo/configs/xdg/git/config"; then
    echo 'SSH still depends on command-specific XDG overrides' >&2
    exit 1
fi
grep -Fqx \
    'alias ssh-copy-id='"'"'ssh-copy-id -i "$XDG_CONFIG_HOME/ssh/id_rsa"'"'"'' \
    "$repo/configs/xdg/zsh/.zshrc"
test "$(grep -Ec '^zinit light (chr-fritz/docker-completion[.]zshplugin|greymd/docker-zsh-completion)$' \
    "$repo/configs/xdg/zsh/.zshrc")" -eq 1
for command in rust uv ty bat eza delta bottom lazygit lazydocker shfmt k9s atuin zk shuck bob kanata; do
    grep -Eq "^${command}[[:space:]]*=" "$repo/configs/xdg/mise/config.toml" ||
        grep -Eq "github:[^\"]*/${command}\"" "$repo/configs/xdg/mise/config.toml"
done
if grep -Eq '^python[[:space:]]*=|^\[settings[.]python\]' \
    "$repo/configs/xdg/mise/config.toml"; then
    echo 'uv, not Mise, should manage development Python' >&2
    exit 1
fi
if rg -q 'jesseduffield/(lazygit|lazydocker)|JohnnyMorganz/StyLua|mvdan/sh|mikefarah/yq|derailed/k9s|zk-org/zk|ewhauser/shuck' \
    "$repo/configs/xdg/zsh/.zshrc"; then
    echo 'Zinit still manages a command-line tool' >&2
    exit 1
fi

find "$repo/scripts" -name '*.sh' -exec bash -n {} +
zsh -n "$repo/configs/xdg/zsh/.zshrc"
