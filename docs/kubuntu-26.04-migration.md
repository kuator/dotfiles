# Kubuntu 26.04 migration checklist

The software setup is ready for migration: the dotfiles and Neovim
repositories are clean, tested, pushed, and the bootstrap supports Kubuntu
26.04.

Do not erase the current installation until the backup and restore checks below
have passed.

## Before wiping the laptop

### Back up personal data

- Optional: configure an encrypted off-site backup using Déjà Dup, Borg, or
  another chosen tool. A backup stored on the laptop's system drive does not
  count for migration.
- [x] Connect `MyHDD`, open it in Dolphin, and confirm that it is mounted at
  `/media/evakuator/MyHDD`.
- [x] Back up `~/Desktop` to `MyHDD/Personal`.
- [x] Back up and checksum-verify `~/Pictures`; no installer ISO was copied.
- [x] Preserve `~/zk` in its private GitHub repository.
- [x] Back up and checksum-verify personal files from `~/Documents`.
- [x] Back up and checksum-verify the work repositories containing laptop-only
  changes under `qazcode_ai`.
- [x] Copy `~/Shared` anime to `MyHDD/torrents`, preserving every source file.
  A final name-and-size dry run found all 778 source files represented at the
  same relative paths with zero unmatched files; this was not a byte-for-byte
  video-content comparison. All 336 external subtitle files were compared
  byte-for-byte and matched, with zero missing or different.
- [ ] Back up the Firefox profile or export bookmarks.
- [ ] Back up Steam `userdata` if any important saves lack Steam Cloud support.
- [ ] Restore several files into a temporary directory and open them.

A backup is not considered working until a restore has been tested.

#### MyHDD personal-file procedure

`MyHDD` is plain ext4, so this section copies only non-secret personal files.
Do not put credentials, `.env` files, Kubernetes configuration, corporate
source, or recovery codes on it unencrypted.

Use the existing personal-backup destination after checking the mount:

```sh
findmnt /media/evakuator/MyHDD
backup_root="/media/evakuator/MyHDD/Personal"
mkdir -p "$backup_root"
printf '%s\n' "$backup_root"
```

Copy personal files without deleting anything already on the destination:

```sh
rsync -aHAX --info=progress2 \
  "$HOME/Desktop/" "$backup_root/Desktop/"

rsync -aHAX --info=progress2 \
  --exclude='/kubuntu-26.04-desktop-amd64.iso' \
  "$HOME/Pictures/" "$backup_root/Pictures/"

rsync -aHAX --info=progress2 \
  --exclude='/books/' \
  --exclude='/NCALayer/' \
  "$HOME/Documents/" "$backup_root/Documents/"

rsync -aHAX --info=progress2 \
  "$HOME/zk/" "$backup_root/zk/"
```

Run the same copies in checksum dry-run mode. No itemized changes means every
source file has matching content in the backup; unrelated extra destination
files are deliberately ignored because these commands do not use `--delete`:

```sh
rsync -aHAXnc --itemize-changes \
  "$HOME/Desktop/" "$backup_root/Desktop/"

rsync -aHAXnc --itemize-changes \
  --exclude='/kubuntu-26.04-desktop-amd64.iso' \
  "$HOME/Pictures/" "$backup_root/Pictures/"

rsync -aHAXnc --itemize-changes \
  --exclude='/books/' \
  --exclude='/NCALayer/' \
  "$HOME/Documents/" "$backup_root/Documents/"

rsync -aHAXnc --itemize-changes \
  "$HOME/zk/" "$backup_root/zk/"
```

- [x] Desktop was copied to `MyHDD/Personal`; `zk` is clean and pushed to its
  private GitHub repository.
- [x] Pictures and Documents checksum dry runs completed with no content
  differences.
- [ ] Several files were restored from `MyHDD` into a new temporary directory
  and opened successfully.

For example, restore the health documents to a new temporary location and open
at least one restored PDF or image before removing the test directory:

```sh
restore_test=$(mktemp -d /tmp/kubuntu-migration-restore.XXXXXX)
rsync -a "$backup_root/Documents/health/" "$restore_test/health/"
find "$restore_test" -type f -ls
printf 'Restore test: %s\n' "$restore_test"
```

### Review the books repository

`~/Downloads/books` was reduced from 3.8 GiB to 1.5 GiB by removing
redownloadable Humble Bundle purchases. Its oversized history was replaced by a
fresh Git LFS root commit in the existing private `kuator/books` repository.

- [x] Back up the collection before rewriting history.
- [x] Remove the redownloadable Humble Bundle subtree.
- [x] Push the current collection through Git LFS.
- [x] Verify a fresh clone, all LFS objects, and source checksums.

### Preserve secrets outside Git

- [x] Back up `~/dev/credentials`.
- [x] Discard the top-level Kubernetes YAML files; the user confirmed they are
  not needed.
- [x] Store the output of `atuin key` in Bitwarden.
- [ ] Confirm that no secret or recovery key is being added to Git.

### Preserve Appgate access

- [x] Store the original Appgate profile file in Bitwarden.
- [x] Decide to reinstall and import the profile instead of migrating old
  Appgate application state.
- [ ] Confirm MFA access before wiping the laptop.
- [x] Exclude the stale real-home `~/.appgate` directory.

After installing Kubuntu, install the pinned Appgate package, configure the
dotfiles wrapper, import the saved profile, and authenticate again. Request
corporate re-enrollment if the profile depends on device-bound registration.

### Verify account and cloud recovery

- [ ] Complete an Anki sync.
- [x] Confirm Bitwarden login and 2FA in a separate session using the
  still-available phone.
- [ ] Confirm Atuin login and cloud sync.
- [ ] Confirm Firefox Sync or export bookmarks manually.
- [ ] Confirm Steam Cloud status for important game saves.
- [x] Preserve the Appgate profile file in Bitwarden.

### Prepare the installation

- [ ] Create and test the Kubuntu 26.04 installation media.
- [ ] Decide the disk and partition layout before starting the installer.
- [ ] Confirm once more that the backup restore test passed.

## After installing Kubuntu

### Bootstrap the machine

```sh
sudo apt-get install -y git
git clone https://github.com/kuator/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./scripts/setup.sh
```

- [ ] Follow the optional system and shell steps in the main README.
- [ ] Log out or reboot when instructed so groups and desktop integration take
  effect.

### Restore applications and accounts

- [ ] Install and configure Firefox using the documented scripts.
- [ ] Install NCALayer using the documented optional script and verify a real
  digital-signature workflow.
- [ ] Install Steam and allow it to restore cloud saves.
- [ ] Install Anki and paste the printed AnkiWeb add-on codes manually.
- [ ] Log into Bitwarden.
- [ ] Log into Atuin and restore its encryption key.
- [ ] Log into Firefox Sync, if used.
- [ ] Log into Anki and complete a sync.
- [ ] Configure the Appgate XDG wrapper, import the saved profile, and complete
  corporate re-enrollment if required.

### Configure KDE and hardware

- [ ] Log out once after installing KWin Minimize2Tray.
- [ ] Verify Plasma Night Light and the keyboard layout.
- [ ] Pair the Sony XM6 fresh with the built-in Bluetooth adapter.
- [ ] Do not migrate `/var/lib/bluetooth` from the old installation.
- [ ] Leave the ASUS BT540 unplugged initially and test BlueZ 5.85 with the
  built-in adapter first.

### Verify the result

```sh
cd "$HOME/dotfiles"
./tests/bootstrap.sh
nvim --version
mise doctor
kreadconfig6 --file kxkbrc --group Layout --key LayoutList
```

- [ ] Restore personal files from the tested backup.
- [ ] Confirm Anki media and cards are present.
- [ ] Confirm Firefox bookmarks and extensions are present.
- [ ] Confirm important Steam saves are present.
- [ ] Confirm Appgate connects.
- [ ] Confirm the XM6 connects, disconnects, and reconnects normally.
