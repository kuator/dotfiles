# Dotfiles

Personal fresh-machine bootstrap for exactly two targets:

- Ubuntu 24.04 with Cinnamon
- Kubuntu 26.04 installed from its ISO with KDE Plasma

The steps below rebuild either machine; commands are run from the repository root unless stated otherwise.

## Fresh-machine runbook

### 1. Clone and bootstrap

```sh
sudo apt-get install -y git
git clone https://github.com/kuator/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./scripts/setup.sh
```

This is the only automatic entry point. It rejects other Ubuntu release/desktop combinations before making changes, asks for sudo normally, installs the base APT packages including Git LFS, installs Appgate, Bitwarden, Ghostty, and Teams-for-Linux, and installs Zinit. It then links the tracked configuration, installs Mise-managed tools including Kanata and Bob's Neovim nightly, installs the subtitle synchronization tools used by mpv, configures desktop-specific window-to-tray and color-temperature support, and applies the tracked desktop keyboard settings. It is safe to rerun: an existing destination is moved to `<name>-old`, and setup stops rather than overwriting an existing backup.

Run every remaining command only after `scripts/setup.sh` succeeds.

### 2. Configure the operating system and login

Disable Snap before installing Firefox, then apply the remaining system and shell changes:

```sh
./scripts/optional/system/disable-snap.sh
./scripts/optional/shell/configure-bash-xdg.sh
./scripts/optional/shell/set-default-zsh.sh
./scripts/optional/system/configure-kanata.sh
./scripts/optional/system/configure-xm6-audio-guard.sh
./scripts/optional/system/configure-ssh-xdg.sh
./scripts/optional/system/disable-sudo-admin-flag.sh
```

The final script applies the legacy home-marker fix on Ubuntu 24.04 and exits without changing anything under Kubuntu 26.04's sudo-rs.

Close every Codex process, then install Codex and its ACP adapter with the Codex home under `$XDG_DATA_HOME`. The script also migrates an existing `~/.codex`:

```sh
./scripts/optional/shell/install-codex.sh
```

Bootstrap installs the verified Appgate `6.5.3+41284+release` Debian package. Install its XDG wrapper afterward:

```sh
./scripts/optional/system/configure-appgate-xdg.sh
```

The Appgate wrapper uses a private fake home under `$XDG_DATA_HOME`; the system service and running VPN client remain vendor software. On Cinnamon/X11 it launches Appgate through KDocker, uses Appgate's installed SVG icon, and starts with the window hidden in the system tray. Wayland and machines without KDocker fall back to the normal Appgate window.

Appgate's **Disconnect** action removes the tunnel, routes, and DNS changes, but leaves the privileged `appgatedriver.service` running. To guarantee that no Appgate process remains active outside work hours, disable its automatic startup once:

```sh
sudo systemctl disable --now appgatedriver.service
```

Start the driver immediately before using Appgate, then disconnect and quit Appgate before stopping it again:

```sh
sudo systemctl start appgatedriver.service
appgate

# After disconnecting and quitting Appgate:
sudo systemctl stop appgatedriver.service
```

Manual starts still work while the service is disabled. Confirm that the driver is stopped with:

```sh
systemctl is-active appgatedriver.service  # expected: inactive
pgrep -x appgate-driver                   # expected: no output
```

An Appgate package reinstall or upgrade may enable the service again; recheck it afterward.

### 3. Log out or reboot

Reboot before continuing. This activates the new login shell, Kanata group membership, system keyboard configuration, and any display-manager changes.

After logging in, `configs/system/keyboard` is the source of truth for layouts and switching. Cinnamon applies it through X11 and KDE derives its keyboard configuration from the same file.

### 4. Configure desktop applications

Install the shared terminal font:

```sh
./scripts/optional/desktop/install-ubuntu-mono-nerd-font.sh
```

Install the pinned official NCALayer 1.4 archive for Kazakhstan digital
signatures. Stop NCALayer first if updating an existing installation. The
installer preserves modules and settings under `~/.config/NCALayer`:

```sh
./scripts/optional/desktop/install-ncalayer.sh
```

Ghostty uses the stable channel by default. On Kubuntu 26.04, opt into the
community nightly package or return to Ubuntu's stable package with:

```sh
GHOSTTY_CHANNEL=nightly ./scripts/bootstrap/install-ghostty.sh
GHOSTTY_CHANNEL=stable ./scripts/bootstrap/install-ghostty.sh
```

The stable command removes the nightly PPA and allows APT to downgrade Ghostty
to Ubuntu's package. Ubuntu 24.04 has no packaged nightly channel.

#### Ubuntu 24.04 Cinnamon

Gammastep starts in the system tray and transitions between the tracked 5500K daytime and 4500K nighttime temperatures. Its duplicate background daemon is masked so only the indicator controls the gamma ramp.

The bootstrap installs KDocker for arbitrary X11 windows. Appgate starts normally; its title-bar close button hides it in the tray, while KDocker's tray-menu **Close** actually quits it. Run `kdocker` and click a window, or use `kdocker -f` for other applications.

Import the GNOME Terminal profile, then apply the LightDM home-cleanup changes used by this machine:

```sh
./scripts/optional/desktop/import-gnome-terminal-profile.sh
./scripts/optional/desktop/lightdm/configure-xauthority.sh
./scripts/optional/desktop/lightdm/patch-binary.sh
```

#### Kubuntu 26.04 KDE

Use Kubuntu's installed KDE terminal and display manager. Do not run the GNOME Terminal or LightDM scripts; the bootstrap has already written KDE's keyboard and repeat settings.

The bootstrap enables Plasma Night Light in dark/light mode at 5500K with a light theme and 4500K with a dark theme. It does not install an external color-temperature daemon on KDE/Wayland.

The bootstrap builds the pinned KWin Minimize2Tray script for Plasma Wayland. Log out and back in after its first installation, then use `Meta+Alt+PgDown` on the active window. Chromium and Electron applications work best when launched in native Wayland mode.

#### Shared applications

Install Firefox after Snap has been disabled:

```sh
./scripts/optional/firefox/install.sh
```

Launch Firefox once so it creates a default profile, then close Firefox and run:

```sh
./scripts/optional/firefox/configure-profile.sh
./scripts/optional/firefox/patch-keybindings.sh
./scripts/optional/firefox/configure-new-tab.sh
```

Install New Tab Override and Vimium through Firefox Add-ons. In New Tab Override, select **Custom URL**, enter `http://127.0.0.1:8766/blank.html`, and enable focusing the website instead of the address bar. In Vimium, set **New tab URL** to **Browser's default new tab page**. Firefox requires these extension changes to be made manually.

The new-tab service binds only to `127.0.0.1`. Firefox updates replace `omni.ja`, so rerun `firefox/patch-keybindings.sh` after an update if the custom browser shortcuts stop working.

Install Valve's Steam package and the fixsteam fake-home launcher:

```sh
./scripts/optional/desktop/install-steam.sh
```

The script preserves the existing library in `$XDG_DATA_HOME/Steam` and installs [fixsteam](https://github.com/Samueru-sama/fixsteam) under `$XDG_DATA_HOME/fixsteam`. Run `steam` once afterwards so fixsteam can create its fake home and desktop launcher. Steam remains outside the automatic bootstrap.

Bootstrap installs the maintained Textractor `260801` build and Protontricks. To launch a Steam visual novel and attach the matching x86/x64 Textractor automatically, set its Steam **Launch Options** to one of these commands:

```sh
# 9-nine-:NewEpisode
steam-textractor %command%

# My Little Sister's Special Place
steam-textractor %command%

# Katawa Shoujo
steam-textractor --target "lib/windows-i686/Katawa Shoujo.exe" %command%
```

The launcher starts the game normally, infers its Windows executable from Steam's command, runs Textractor inside that game's Proton prefix, selects x86 or x64, and records the exact Windows path for retrying auto-attach. Use `--target` only when Steam starts a launcher that spawns a different executable, as Katawa Shoujo does. Close Textractor before exiting the game so it can detach its hook cleanly. The old per-prefix Textractor installation can remain until the shared setup has been tested.

### 5. Restore Japanese study tools

Install Anki, link mpv configuration, install mpvacious, and check the Anki add-on manifest:

```sh
./scripts/optional/japanese/setup.sh
```

Paste any printed codes into **Anki → Tools → Add-ons → Get Add-ons**, then restart Anki. After add-on `1045800357` exists, restore its optional 2.5 GiB local-audio collection:

```sh
./scripts/optional/japanese/download-yomitan-audio.sh
```

The torrent and archive stay in `${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/yomitan-audio`; the main bootstrap never starts this download.

The Japanese setup installs add-on `580654285` from the pinned `kuator/yomichan-forvo-server` fork instead of AnkiWeb. This keeps slow or unavailable Forvo lookups from blocking Yomitan card creation for longer than the configured five-second total timeout. The installer preserves existing add-on settings, disables AnkiWeb updates for this checkout, and can also be run on its own:

```sh
./scripts/optional/japanese/install-yomitan-forvo-server.sh
```

The eight selected Yomitan dictionary ZIPs are carried directly in `japanese/yomitan/dictionaries/`. If an archive is missing, restore it from the manifest:

```sh
./scripts/optional/japanese/download-yomitan-dictionaries.sh
```

In Yomitan, import the numbered archives from `japanese/yomitan/dictionaries/`, then import `japanese/yomitan/settings.json` from **Settings → Backup → Import Settings**. Follow `japanese/yomitan/README.md` to apply the tracked order to the currently selected profile.

Finally, start Anki with AnkiConnect enabled and update or create the official Japanese Sentences note type with the local compatibility changes:

```sh
./scripts/optional/japanese/update-japanese-sentences.sh
```

The local template keeps images expanded on mobile, places them directly below the sentence on the answer side before definitions and notes, and presents Yomitan dictionary provenance as compact colored labels while retaining the full dictionary name in the card HTML and label tooltip. Restart Anki afterward so AJT Japanese refreshes its injected CSS and JavaScript.

Normal runs use a reviewed, pinned upstream commit. Check for upstream changes without modifying Anki, then explicitly test a reviewed commit if one is available:

```sh
./scripts/optional/japanese/update-japanese-sentences.sh --check-upstream
./scripts/optional/japanese/update-japanese-sentences.sh --upstream-ref <40-character-commit>
```

The second command is a one-time override. After accepting the result, update `upstream_ref` near the top of the script so future normal runs keep that revision; otherwise, a normal run deliberately restores the existing pin.

The updater also maintains a local `VocabFreq` field, displayed as compact JPDB/CC100 labels on answer sides. Import the tracked Yomitan settings so newly mined notes fill it with `{frequencies}`.

### Restore the LeetCode study deck

Bootstrap downloads the reviewed LeetCode Superset package from a pinned
revision and verifies its SHA-256 checksum. It installs the package under
`${XDG_DATA_HOME:-$HOME/.local/share}/leetcode-anki` without modifying the
personal Anki collection. After Anki is running with AnkiConnect enabled,
import it idempotently with:

```sh
./scripts/bootstrap/install-leetcode-anki.sh --import
```

The package contains 574 problem cards despite its upstream `600` name. Each
card contains the problem statement and a Python answer; most also include an
approach explanation and explicit complexity analysis. Importing also applies
the tracked `configs/anki/leetcode.css`, which constrains line length and fixes
the upstream code blocks in both light and dark mode. The source repository is
`https://github.com/VarunVankineni/leetcode-anki-apkg`.

To recover a missing book title on cards created from copied EPUB text, preview exact matches first, then apply the reviewed changes:

```sh
./scripts/optional/japanese/attribute-epub-cards.py ~/Books/book.epub
./scripts/optional/japanese/attribute-epub-cards.py ~/Books/book.epub --apply
```

### 6. Verify the machine

```sh
./tests/bootstrap.sh
nvim --version
mise doctor
test ! -e "$HOME/.appgate" && echo 'Appgate home is clean'
```

On Ubuntu 24.04 Cinnamon/X11, also run `setxkbmap -query`. On Kubuntu 26.04, run `kreadconfig6 --file kxkbrc --group Layout --key LayoutList`. The first command above is the repository regression suite; the others are quick checks of installed tools and machine-level changes.

## Repository map

### Configurations and study resources

- `configs/home/profile` defines the login environment, XDG locations, and user-tool paths and is linked to `~/.profile`.
- `configs/xdg/` contains application configuration linked into `$XDG_CONFIG_HOME`, grouped by application. Notable exceptions handled specially by the linker are Codium's files and the global `ty.toml`. Atuin records contextual shell history with secret filtering while leaving the existing `fzf` and arrow-key bindings untouched.
- `configs/xdg/xm6-audio-guard/` mutes fallback outputs when the paired Sony WH-1000XM6 disappears and unmutes only the headphones when they reconnect.
- `configs/system/keyboard` is the single tracked source for the system, Cinnamon, KDE, IBus, and live X11 keyboard layout; `configs/gnome-terminal/profile.dconf` is imported rather than linked.
- `docs/ergonomic-keyboard.md` records the ergonomic-keyboard requirements, shortlist, and current recommendation.
- `docs/backups-and-qol.md` records the personal-backup scope, encrypted GitHub option, restore requirements, and quality-of-life software shortlist.
- `docs/kubuntu-26.04-migration.md` is the pre-wipe and post-install migration checklist.
- `docs/todo.md` tracks setup that still requires an external account or private recovery material.
- `japanese/anki/addons.txt` is the named AnkiWeb add-on manifest; the pinned Forvo fork is installed separately.
- `japanese/yomitan/dictionaries.txt`, `japanese/yomitan/settings.json`, and `japanese/yomitan/sort-dictionaries.js` define the selected dictionaries, exported settings, and active-profile order.
- `japanese/anime/` contains older subtitle timing tools and source-specific data; it is not part of bootstrap.

### Automatic bootstrap

- `scripts/setup.sh` is the only entry point.
- `scripts/bootstrap/install-packages.sh` installs Ubuntu packages.
- `scripts/bootstrap/install-appgate.sh` installs the pinned official Appgate 6.5.3 build after verifying its SHA-256 checksum and package metadata.
- `scripts/bootstrap/install-bitwarden.sh` installs the pinned official Bitwarden desktop package after verifying its SHA-256 checksum.
- `scripts/bootstrap/install-ghostty.sh` uses the stable channel by default. It installs Ghostty 1.3.1 from a pinned, checksummed community Debian package on Ubuntu 24.04 and Ubuntu's signed archive package on Kubuntu 26.04. On Kubuntu, run `GHOSTTY_CHANNEL=nightly ./scripts/bootstrap/install-ghostty.sh` to enable the community nightly PPA and update to its newest package; run with `GHOSTTY_CHANNEL=stable` to remove that PPA and safely downgrade to Ubuntu's package. Nightly binaries are unavailable for Ubuntu 24.04.
- `scripts/bootstrap/install-teams-for-linux.sh` installs the deliberately pinned upstream Teams-for-Linux 2.8.0 Debian package after verifying its SHA-256 checksum and package metadata.
- `scripts/bootstrap/link-configs.sh` backs up and links tracked configuration.
- `scripts/bootstrap/install-mise.sh` installs Mise-managed CLI tools and Bob's Neovim nightly.
- `scripts/bootstrap/install-textractor.sh` installs the pinned maintained Textractor build, its Unicode font, and Protontricks for Steam-prefix launching.
- `scripts/bootstrap/install-subtitle-sync.sh` installs pinned ffsubsync through uv, alass-cli through the Mise-managed Rust toolchain, and autosubsync-mpv under mpv's scripts directory.
- `scripts/bootstrap/install-leetcode-anki.sh` installs a pinned, checksummed LeetCode Superset package and can import it idempotently through AnkiConnect.
- `scripts/bootstrap/install-window-tray.sh` uses Ubuntu's KDocker package on Cinnamon/X11 and installs pinned KWin Minimize2Tray on KDE/Wayland.
- `scripts/bootstrap/configure-desktop.sh` derives desktop keyboard settings from `configs/system/keyboard` and selects Ghostty as the default terminal in Cinnamon and KDE.
- `configs/system/tmpfiles.d/cpu-energy-preference.conf` keeps CPU boost available with the less aggressive `balance_performance` energy preference. Bootstrap applies it only when every exposed CPU policy advertises support, so unsupported laptop and desktop CPUs keep their defaults.
- On Cinnamon, Gammastep starts through XDG autostart after the display is ready; its early-starting vendor user units are masked.

### Manual setup

Nothing under `scripts/optional/` runs automatically. Several scripts use sudo, alter installed software, or require an application to be open or closed.

| Script | Purpose |
| --- | --- |
| `desktop/import-gnome-terminal-profile.sh` | Imports the tracked GNOME Terminal profile. |
| `desktop/install-ncalayer.sh` | Installs the pinned official NCALayer archive while preserving user modules and settings. |
| `desktop/install-steam.sh` | Installs Valve's Steam package and fixsteam fake-home launcher. |
| `desktop/install-ubuntu-mono-nerd-font.sh` | Downloads and installs UbuntuMono Nerd Font. |
| `desktop/lightdm/configure-xauthority.sh` | Stores LightDM Xauthority data outside the home root. |
| `desktop/lightdm/patch-binary.sh` | Patches LightDM to move `.xsession-errors`; use only with LightDM. |
| `firefox/configure-new-tab.sh` | Enables the localhost-only tracked new-tab page service. |
| `firefox/configure-profile.sh` | Links Firefox preferences and content CSS into its default profile. |
| `firefox/install.sh` | Installs Firefox from the Mozilla Team PPA. |
| `firefox/patch-keybindings.sh` | Rebuilds Firefox's `omni.ja` with the custom shortcuts. |
| `japanese/download-yomitan-audio.sh` | Downloads, caches, and installs the optional local-audio collection. |
| `japanese/download-yomitan-dictionaries.sh` | Restores missing dictionary archives from the tracked manifest. |
| `japanese/install-yomitan-forvo-server.sh` | Installs the pinned Forvo audio-server fork while preserving its settings. |
| `japanese/setup.sh` | Installs Anki and mpvacious and reports missing Anki add-ons. |
| `japanese/attribute-epub-cards.py` | Previews or restores EPUB book titles on matching Japanese Sentences notes. |
| `japanese/update-japanese-sentences.sh` | Fetches upstream Japanese Sentences, applies compatibility patches, and updates it through AnkiConnect. |
| `shell/configure-bash-xdg.sh` | Makes system Bash startup and history use XDG locations. |
| `shell/install-codex.sh` | Installs Codex and `codex-acp` through Mise-managed npm with an XDG data home and migrates an existing `~/.codex`; Codex must be closed. |
| `shell/set-default-zsh.sh` | Interactively changes the login shell to Zsh. |
| `system/configure-appgate-xdg.sh` | Installs the Appgate fake-home wrapper with `dpkg-divert`. |
| `system/configure-kanata.sh` | Configures Linux groups, udev, and uinput, then enables the tracked Kanata user service. |
| `system/configure-xm6-audio-guard.sh` | Enables the user service that prevents audio from spilling to speakers when the XM6 disconnects. |
| `system/configure-ssh-xdg.sh` | Makes all OpenSSH clients use the tracked XDG config and migrates host keys. |
| `system/disable-snap.sh` | Removes Snap while preserving user data and prevents its reinstallation. |
| `system/disable-sudo-admin-flag.sh` | Prevents classic sudo from creating its home marker; safely does nothing under sudo-rs. |

### Wrapper

- `bin/appgate` gives the vendor Appgate client a private fake home.
- `bin/codium` launches VSCodium with its XDG data directory.
- `bin/fd` exposes Ubuntu's `fdfind` executable under its upstream `fd` name.
- `bin/fix-xm6-audio` repairs a stale XM6 Bluetooth audio transport and restores the headphones as the default output.
- `bin/rg` makes ripgrep share the ignore file used by fd.
- `bin/steam` launches the optional fixsteam installation from its XDG data path.
- `bin/steam-textractor` starts a Steam game and automatically attaches the matching Textractor build inside its Proton prefix.

### Test

- `tests/bootstrap.sh` checks links, environment settings, desktop configuration, wrappers, migrations, and documented scripts.
- `tests/python-environment.sh` checks the `venv`-based uv and ty project environment.
- `tests/update-japanese-sentences.sh` exercises note-type download, patching, and AnkiConnect behavior with local fakes.
- `tests/xm6-audio-guard.sh` simulates XM6 disconnect/reconnect events and verifies safe muting without touching live audio.
- `tests/yomitan-sort-dictionaries.js` checks dictionary ordering without Yomitan.

### Downloaded/vendor content

- `japanese/anki/addons21/` contains downloaded Anki add-ons and is intentionally ignored; `japanese/anki/addons.txt` lists AnkiWeb sources, while the Forvo fork is pinned in its installer.
- `japanese/yomitan/dictionaries/` contains the eight Git-tracked importable archives. Their internals are third-party data and are not documented here.
- `configs/xdg/mpv/scripts/mpvacious/` and `configs/xdg/mpv/scripts/autosubsync-mpv/` are ignored generated checkouts. `japanese/setup.sh` installs a pinned commit from the `kuator/mpvacious` fork, while the automatic bootstrap installs a pinned autosubsync-mpv commit and its ffsubsync and alass backends.

## Maintenance rule

Put general declarative configuration under `configs/` and Japanese study resources under `japanese/`. Put automatic fresh-machine work under `scripts/bootstrap/` and call it from `scripts/setup.sh`; put destructive, optional, application-dependent, or machine-level work under the matching `scripts/optional/` responsibility folder. Add a regression check when behavior—not just data—changes.
