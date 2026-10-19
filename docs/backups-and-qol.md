# Backups and quality-of-life software

## Current backup risk

The laptop currently has no usable second copy of personal files. Only the
internal SSD is mounted, and Deja Dup is installed but has never completed a
backup and does not have automatic backups enabled. Git repositories make the
machine reproducible, but they do not protect personal files or unpushed work.

The August 2026 audit found these approximate sizes:

| Location | Size | Decision |
| --- | ---: | --- |
| `~/Downloads/books` | 1.6 GiB | Backed up and stored in private GitHub using Git LFS |
| `~/Documents/NCALayer` | 265 MiB | Exclude; reinstallable software |
| Other files in `~/Documents` | 19 MiB | Back up |
| `~/Pictures` | 377 MiB | Back up |
| `~/Desktop` | 57 MiB | Back up |
| `~/zk` | less than 1 MiB | Back up |
| `~/.local/share/Anki2` | 3.9 GiB | Exclude; rely on Anki sync |
| `~/Videos` | 20 GiB | Exclude; downloaded anime |
| `~/Downloads` | 11 GiB | Exclude; replaceable downloads |

The `~/Downloads/books` repository was rebuilt as a fresh Git LFS snapshot and
verified through a clean clone. Redownloadable Humble Bundle purchases are
excluded. The repository is recoverable from private GitHub, while the separate
file backup remains useful against account or LFS availability problems.

## Recommended backup plan

If using the already installed Deja Dup, choose an off-site destination such as
Google Drive, enable encryption and automatic backups, and include only:

- `~/Documents`, excluding `books` and `NCALayer`;
- `~/Desktop`;
- `~/Pictures`;
- `~/zk`;
- any work repository that may contain uncommitted or unpushed work.

After the first backup, restore several files into a temporary directory and
open them. A backup is not considered working until a restore has been tested.
Store the encryption password in Bitwarden and keep a second offline recovery
copy. Losing the password makes an encrypted backup unrecoverable.

An external SSD can later provide another local copy, but it should supplement
the off-site copy rather than replace it. A drive stored with the laptop does
not protect against theft, fire, or damage to both devices.

Do not store the only backup on the laptop's system drive. Such a copy is lost
with disk failure or an OS reinstall and does not satisfy the migration backup
requirement.

## Optional encrypted GitHub copy

GitHub can hold an additional emergency copy of the small, irreplaceable
subset, but it is not a good primary backup service.

`age` is an open-source file-encryption tool. The safe shape is to create an
archive containing the selected files, encrypt the archive with `age`, and
upload only the resulting `.age` file to a private repository. Keeping files
inside one archive also conceals their filenames. The decryption identity must
be stored in Bitwarden and offline, never in the repository. An implementation
must avoid leaving an unencrypted temporary archive behind and must include a
tested restore command.

Keep this copy small. GitHub rejects normal Git objects larger than 100 MiB,
recommends repositories stay below 1 GiB, and is inefficient for repeated
encrypted archives: encryption changes the whole archive, so Git stores another
large object for every snapshot. Git LFS can raise the per-file limit, but each
version consumes the account's LFS storage quota. This is why Deja Dup remains
the recommended automatic backup.

## Quality-of-life software shortlist

1. **KDE Connect** — install when moving to Kubuntu, or earlier if phone
   integration is useful now. It provides clipboard sharing, notifications,
   file and link transfer, phone battery status, media control, and remote
   input.
2. **Syncthing** — optional for continuously synchronizing selected folders
   between the laptop, a future PC, and a phone. Synchronization is not backup:
   deletion and corruption can propagate to every device.
3. **tealdeer** and **duf** — optional terminal conveniences for concise command
   examples and readable disk-space summaries.
4. **scrcpy** — optional if the phone is Android and desktop control or mirroring
   would be useful.

Do not add another clipboard manager, launcher, screenshot application, or
system monitor just for Kubuntu. Plasma already provides Klipper and KRunner,
and the current setup already contains Flameshot and terminal monitoring tools.
