# Handoff

## Continuation guidance

Treat repository state as authoritative if it conflicts with this file. Inspect
status/diffs before acting, preserve unrelated changes, and do not reconstruct
completed investigation. Do not commit or push unless requested. Use
`kuator <kuator578@gmail.com>` for commits.

## Current objective

Prepare this laptop for a fresh Kubuntu 26.04 installation without losing
personal data, secrets, or laptop-only development work.

The corporate `~/dev/work/beeline/qazcode_ai` backup is complete. It was copied
in plaintext at the user's explicit request to
`/media/evakuator/MyHDD/Personal/qazcode_ai`, with virtual environments,
dependency directories, build outputs, and caches excluded. `MyHDD` remains
mounted for the remaining migration backups.

## Completed in this session

- Dotfiles commit `af246a6` (`feat: automate appgate and textractor setup`) was
  pushed to `origin/main` as `kuator`. It added the pinned official Appgate
  `6.5.3+41284+release` installer, maintained Textractor `260801`, pinned
  Protontricks `1.13.1`, `steam-textractor`, and Firefox
  `media.av1.enabled=false`.
- Neovim was already clean and pushed at `d82d96f` (`feat: improve completion
  and lazy loading`).
- `~/zk` was initialized as the private `kuator/zk` repository and pushed at
  `7c9c96a`. `.zk/notebook.db*` is ignored. A secret scan found only OAuth code
  examples, not credentials.
- `docs/kubuntu-26.04-migration.md` was created and linked from `README.md`.
  These two changes are currently uncommitted.
- `~/dev/work/beeline/qazcode_ai` was copied to
  `MyHDD/Personal/qazcode_ai` without encryption at the user's explicit request.
  The copy contains 20,835 entries, about 477 MB of logical file data, and all
  seven Git directories. An `rsync -aHAXnc --itemize-changes` pass with the
  same exclusions produced no output, and `git fsck --full` completed for all
  seven repositories with only normal dangling-object reports. Registered
  `/tmp` worktrees were stale; none of their directories still existed.
- The books collection moved to `~/Downloads/books`. The redownloadable 2.23
  GiB `software_development_books/HumbleBundle` subtree was removed. The
  existing private `kuator/books` repository was replaced with a fresh Git LFS
  root commit `f9741eb`; 299 paths use LFS and 283 unique objects totaling about
  1.5 GB were uploaded. A fresh clone, `git lfs fsck`, remote-OID check, and
  checksum comparison passed. Old local Git history and the verification clone
  were then permanently deleted; `.git` shrank from 3.9 GB to 13 MB.
- `~/Pictures` (414 MB) and `~/Documents` (275 MB) are present under
  `MyHDD/Personal`; checksum dry runs found no content differences and the
  Pictures copy contains no ISO. `~/.config/NCALayer` was copied to
  `MyHDD/Personal/NCALayer`; its checksum pass found only timestamp differences.
  `~/Desktop` was copied to `MyHDD/Personal/Desktop`; `~/zk` is clean and
  pushed to its private GitHub repository.
- The anime under `~/Shared` was copied (not moved) to `MyHDD/torrents` with
  the source tree authoritative. After the initial 12 missing top-level entries,
  274 missing or size-different files were copied: 223 subtitles, 36 videos,
  and 15 supporting files (12,152,176,117 bytes). A final dry run found all 778
  source files represented at the same relative name and byte size, with zero
  unmatched files. All 336 external subtitle files (137 ASS, 173 SRT, and 26
  SUP; 1.27 GB total) were then compared byte-for-byte: all were identical,
  with zero missing or different. Video contents were not checksummed.
- Health documents were restored from Trash to `~/Documents/health`:
  `06-2027_Research_HealthCertificate.pdf` and
  `translated_health_certificate_ru.pdf`.
- Bitwarden 2FA was enabled and tested in a separate login. Saving the
  Bitwarden recovery code outside the vault, Google backup codes, and an
  authenticator recovery plan are separate account-hardening tasks and
  explicitly not Kubuntu migration blockers while the phone remains available.
- The XM6 was cleanly re-paired to the built-in controller
  `F8:54:F6:E8:47:CE`; stale records for old ASUS controller
  `F0:2F:74:77:16:30` and the incomplete built-in record were deleted. Manual
  verification showed Paired/Bonded/Trusted/Connected `yes`, LDAC stereo
  48 kHz, and battery 57%.
- Firefox video testing confirmed YouTube changed from software-decoded AV1 to
  VP9 after the pref change. RDD CPU fell from about 22% to below 3%; sustained
  temperature fell from 72-74C to about 61-62C.
- The following dump directories were permanently deleted after verifying they
  were untracked/ignored: `qazcode_ai/prod_dump_20260810_without_checkpoint_payloads`
  (11 GB) and `qazcode_ai/opengpts/backend/prod-dumps` (7.9 GB).
- `./tests/bootstrap.sh`, shell syntax checks, and `git diff --check` passed
  before `af246a6` was committed. The Textractor archive checksum is
  `86346c71ba961e993b8b40419d8720204ccaf8fe20606bbd267eb765ba2ff2ef`.
- Teams-for-Linux `2.8.0` was added to the automatic bootstrap using the
  official AMD64 Debian release and its published SHA-256 checksum. The
  installer, setup integration, documentation, and tests are uncommitted.
- Ghostty and Git LFS were added to the automatic bootstrap. Ubuntu 24.04 uses
  the pinned Ghostty `1.3.1-0~ppa1` community Debian artifact with checksum
  verification because no Noble nightly is published. Kubuntu 26.04 defaults
  to Ubuntu's stable package; `GHOSTTY_CHANNEL=nightly` opts into
  `ppa:mkasberg/ghostty-ubuntu-nightly`, while `GHOSTTY_CHANNEL=stable` removes
  it and permits the required downgrade. Git LFS is installed with the base APT
  packages because the tracked Git config requires its filters. These changes
  are uncommitted.
- Ghostty is now selected as the default terminal by the automatic desktop
  configuration: Cinnamon receives its terminal GSettings, KDE receives both
  `TerminalApplication=ghostty` and
  `TerminalService=com.mitchellh.ghostty.desktop`, and the generic/Cinnamon XDG
  terminal preference lists are tracked. Bootstrap tests pass; these changes
  are uncommitted.

## Current implementation and decisions

### Kubuntu migration and backup

- Automatic setup explicitly supports Ubuntu 24.04 Cinnamon and Kubuntu 26.04
  KDE. The main runbook is `README.md`; the actionable checklist is
  `docs/kubuntu-26.04-migration.md`.
- Git/cloud-reproducible or disposable data should not inflate the backup.
  `~/Shared` (about 135 GiB) and `~/Videos` (20 GB) are downloaded anime.
  `~/Downloads/Telegram Desktop` (4 GB) is disposable. `~/opt` is
  reinstallable. `~/Pictures` is 5.2 GB only because the Kubuntu ISO is 4.8 GB;
  the remaining pictures are small enough to back up wholesale.
- Déjà Dup has never completed a backup (`last-backup=''`) and automatic backup
  is disabled. It is optional and useful only with an external/network/off-site
  destination; a backup on the laptop's system disk does not count. Migration
  safety currently depends on the MyHDD copies and a successful restore test.
- `MyHDD` previously appeared as plain ext4, not encrypted. Corporate source,
  Vault plans, credentials, and `.env` files should not be left on an
  unencrypted portable drive without an explicit decision.
- Copy full repositories with `.git` so branches, stashes, local commits, and
  untracked work survive. Use `rsync -aHAX` without `--delete`; exclude
  `venv/`, `.venv/`, `node_modules/`, `__pycache__/`, test/tool caches,
  `dist/`, and `build/`. Verify with a checksum dry run.

### Development repositories

- `~/dev/personal/test_django_project` is explicitly disposable.
- OpenGPTs `dev` matches `origin/dev`. Its only change is clean submodule
  `vendor/ssrf-guard` checked out at `65951aa` instead of recorded `ac2e5da`;
  a fresh submodule update restores it, so no backup is needed for that change.
- `client_service` `dev` matches `origin/dev`, but has 21 untracked
  Vault/cleanup scripts/manifests plus two local stashes from 2025-11-13. These
  are laptop-only and potentially sensitive; preserve through an encrypted
  whole-tree backup unless explicitly discarded.
- `qazcode-mcp` has 3 dirty files and 4 unpushed commits. `qazcode-worker` has
  7 dirty files and 7 unpushed commits. Corporate changes must go only to
  approved corporate remotes or encrypted backup, never personal GitHub.
- The user explicitly declared `CV`, `algorithms-and-stuff`,
  `kuator.github.io`, and `mcp-server-with-google-auth` disposable. Do not back
  them up; this also includes the personal project's `.env`.

### Bluetooth/XM6

- ASUS BT540 is not active; the built-in IMC Bluetooth radio is used. Do not
  migrate `/var/lib/bluetooth` or reconnect the ASUS dongle during initial
  Kubuntu testing.
- Ubuntu 24.04 BlueZ 5.72 sometimes leaves a ghost `Connected: yes` after the
  powered-off XM6 has physically disconnected. Logs show status `0x0e` while
  D-Bus remains stale. Restarting Bluetooth and WirePlumber clears it without
  deleting the valid bond. Kubuntu 26.04 carries BlueZ 5.85, PipeWire 1.6.0,
  and WirePlumber 0.5.13, so retest before adding an auto-connect workaround.
- USB autosuspend and SBC-XQ experiments did not fix cuts and were reverted;
  LDAC remains the chosen codec. Phone multipoint reduced but did not entirely
  explain cuts.

### Other deliberate decisions

- Teams-for-Linux remains deliberately pinned at installed version `2.8.0` and
  should not be updated for now. The bootstrap now reproduces that exact
  version and refuses to silently replace a different installed version.
- Games are for reading/lookups only, not Anki mining. `steam-textractor`
  launches the shared maintained Textractor build in the correct Proton prefix.
- Books and anime remain the intended Anki mining sources. Existing
  `MyJapanese` VocabKanji audit: 1,114 notes, 1,082 unique targets, 32 exact
  duplicate pairs, no blanks; no bulk cleanup recommended.
- Old HP 15-series 1 TB SSD recovery is deferred. Keep it powered off. Future
  recovery requires at least 1 TB destination space (preferably 2 TB), a live
  Linux environment, and GNU ddrescue imaging with a mapfile; never run fsck or
  repair the source drive.

## Git/worktree state

- Dotfiles: `main`, tracking `origin/main` at `af246a6`. Preserve the current
  uncommitted migration documentation and Teams-for-Linux bootstrap work in
  `README.md`, `HANDOFF.md`, `docs/kubuntu-26.04-migration.md`,
  `scripts/setup.sh`, `scripts/bootstrap/install-ghostty.sh`,
  `scripts/bootstrap/install-packages.sh`,
  `scripts/bootstrap/install-teams-for-linux.sh`, and `tests/bootstrap.sh`.
- Neovim: `/home/evakuator/.config/nvim` remains on `main` at `d82d96f` but
  has uncommitted native-completion promotion work. The default profile now
  eagerly loads `minibuffer.nvim` on top of Neovim UI2 with command-line
  autotrigger disabled. `vim.ui.select`/`vim.ui.input`, ZK, `<leader>sl`,
  `<leader>sf`, `<leader>sr`, and `:ListEnvs` use Minibuffer; `<leader>ff`
  deliberately remains the argv-safe fd-backed native `:find` workflow, and
  `<leader>lg` remains `:lgrep` with the location list. Telescope and its four
  unused companion packages remain removed only from the default profile;
  `/home/evakuator/.config/nvim-native` retains the previous Telescope setup as
  a fallback. Minibuffer's asynchronous file builtin currently delivers its
  `vim.system()` result from a fast-event callback and triggers E5560 in
  `matchfuzzy`; `plugin/01_minibuffer.lua` wraps picker fetch callbacks with
  `vim.schedule_wrap` until upstream fixes it. The same wrapper adds Normal-mode
  selection navigation: Insert-mode `<Esc>` enters Normal mode, `j`/`k` move,
  `<CR>`/`<C-y>` accept, and `q`/`<Esc>` cancel. Real-TUI checks populated
  `<leader>sf` and verified an index change from 1 to 2 with `j`. Lazy loading, lazy
  commands, removed-plugin checks,
  `git diff --check`, JSON validation, and a real-TUI `:checkhealth minibuffer`
  pass. The health check incorrectly reports UI2 absent under `--headless`
  because no command window exists there. None of these Neovim changes are
  committed or pushed.
- ZK: `/home/evakuator/zk`, clean `main` at `7c9c96a`, tracking private
  `origin/main`.
- Books: `/home/evakuator/Downloads/books`, clean `main` at `f9741eb`, tracking
  the private `origin/main`. Book binaries are managed by Git LFS; Humble Bundle
  purchases are excluded as redownloadable. Do not rewrite or push this
  repository again unless explicitly requested.
- Mpvacious upstream `master` is at `a38274d` and includes merged PRs #182
  (secondary delay), #183 (tiny overlap filtering), and #184 (exported note
  helper). The live checkout is the local-only `local-integration-20260906`
  branch at `572a259`: current upstream plus the still-open #177 and #180
  changes. Do not push this combined branch. PR #177 was refactored into a
  thin observer integration plus a dedicated secondary-subtitle scanner, then
  force-pushed with an exact lease as commit `4b6ea3a` to
  `kuator/feat/full-track-secondary-overlap`. PR #180 was refactored so that
  mismatch detection and confirmation state live in `note_update_guard.lua`,
  leaving `note_exporter.lua` to coordinate the update; commit `1854e7d` was
  force-pushed with an exact lease to
  `kuator/fix/confirm-mismatched-recent-notes`. `git ls-remote` confirms both
  remote branch heads. `luajit tests/run.lua` and `git diff --check` pass for
  each PR and for the combined live checkout. A headless mpv run loaded the
  combined script successfully against a real media file without Lua errors.
  The `recovery/pr-{177,180}-before-style-20260906` refs preserve the replaced
  PR tips; the previous combined branch and older recovery refs remain.
  Interactive visual/behavioral verification during a real mining session is
  still pending.

## Known unresolved issues and manual checks

- No verified personal backup exists; Trash still held about 1.6 GB at last
  check and contains personal, identity, educational, corporate, and secret
  files. Do not empty it before review.
- `~/dev/credentials` is backed up. The top-level Kubernetes YAML files were
  deleted as unnecessary, there is no dotfiles `.env`, and the Atuin encryption
  key is stored in Bitwarden. Migration secret storage is complete.
- Cloud checks still manual: successful Anki sync, Firefox Sync/bookmark export,
  Steam Cloud saves, and Atuin sync. Bitwarden login/phone 2FA was already
  tested, and the Appgate profile file is stored in Bitwarden; Appgate MFA is a
  post-install connection check, not a pre-wipe blocker.
- Textractor automated tests passed, but a real Steam VN launch/injection test
  has not been performed. Steam launch options were written for apps 1890120,
  1977740, and 3068300; original localconfig backup is
  `~/.local/share/Steam/userdata/1841849285/config/localconfig.vdf.before-steam-textractor-20260820`.
- Deferred Neovim manual checks: fresh-process `:Mas<Tab>` and
  `:CodeComp<Tab>`. Automated lazy-command tests passed before `d82d96f`.
- The `Japanese sentences` Anki notes were audited and repaired through
  AnkiConnect. The original 1,423-note audit regenerated `SentFurigana` for 140
  substantive sentence mismatches and added four missing `SentKanji` bold
  highlights. On 2026-09-01, after the collection grew to 1,774 notes, another
  35 substantive `SentKanji`/`SentFurigana` divergences were regenerated from
  authoritative `SentKanji`; the backup is
  `/tmp/anki-35-divergent-notes-before-repair-20260901.json`. The separate
  missing `SentKanji` highlight on note `1788187600907` was then repaired. The
  latest structural audit covered 1,777 notes and found zero substantive
  sentence differences, missing/mismatched highlights, vocabulary surface
  differences, unbalanced fields, missing referenced media files, or card-count
  errors. Nineteen harmless typography-only differences remain. Note
  `1786472440491` is intentionally tagged `needs-media` and lacks sentence audio
  and an image; 73 notes lack optional standalone vocabulary audio but retain
  sentence audio. AnkiWeb sync is still pending.
- `bin/fix-xm6-audio` still has a BlueZ timing race: after restarting Bluetooth,
  an asynchronous connection can finish after its sink timeout, so it may
  report failure even though recovery completes later. It was not changed.
- The optional Kubuntu Ghostty nightly channel is configured correctly, but its
  newest published PPA package was
  `1.3.2+nightly20260722T0416~ppa2-resolute1` when checked on 2026-08-22. The
  latest ten scheduled packaging workflows were all failing at the Ghostty
  build step because upstream tip now requires Zig 0.16.0 while the community
  workflow still requests 0.15.2. Stable remains the bootstrap default;
  explicitly opting into nightly currently gets that July build and will
  resume updating if the maintainer repairs the workflow.
- The unsupported Neovim invocation
  `nvim --headless -l tests/lazy_commands.lua` previously reported `Telescope
  was not restored`; the supported fresh-process form
  `nvim --headless -c 'luafile tests/lazy_commands.lua'` passed.
- A stale real-home `~/.appgate` directory from 2026-08-14 still exists. The
  `/usr/bin/appgate` diversion/fake-home wrapper is correct and current Appgate
  state lives under `~/.local/share/appgate/home`; do not migrate the stale
  directory.

## Relevant files and paths

- Migration: `README.md`, `docs/kubuntu-26.04-migration.md`,
  `docs/backups-and-qol.md`, and `docs/todo.md`.
- Reproducible desktop additions: `scripts/bootstrap/install-appgate.sh`,
  `scripts/bootstrap/install-ghostty.sh`,
  `scripts/bootstrap/install-teams-for-linux.sh`,
  `scripts/bootstrap/install-textractor.sh`, `bin/steam-textractor`,
  `configs/xdg/firefox/user.js`, `scripts/setup.sh`, and `tests/bootstrap.sh`.
- Completed corporate backup:
  `/media/evakuator/MyHDD/Personal/qazcode_ai`; source
  `~/dev/work/beeline/qazcode_ai`.
- Personal data/recovery: `~/Documents/health`, `~/Pictures`, `~/Desktop`,
  `~/zk`, and `~/.local/share/Trash`. `~/dev/credentials` is already backed
  up.
- Bluetooth: `bin/fix-xm6-audio` and
  `configs/xdg/xm6-audio-guard/`.

## Exact next steps

1. Review Trash and restore/back up any remaining personal, identity,
   educational, work, and secret files; perform a real restore test.
2. Verify Anki, Firefox, Steam, and Atuin sync.
3. Commit and push the intentional dotfiles migration/handoff documentation
   changes when requested.
4. Safely unmount `MyHDD` after all migration copies and restore tests finish.
5. Create/test the Kubuntu USB and migrate only after the restore test passes.
   Pair XM6 fresh with the built-in adapter and do not migrate BlueZ state.
