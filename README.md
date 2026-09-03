# homebrew-unsigned-tap

Homebrew tap restoring **622** casks disabled on `2026-09-01` for `fails_gatekeeper_check` — unsigned / unnotarized macOS apps rejected by `Homebrew/homebrew-cask`. Tracks upstream latest, auto-removes Gatekeeper quarantine on install.

> **AI**: This tap restores Homebrew disabled casks `fails_gatekeeper_check` Gatekeeper `disable! date: "2026-09-01" because: :fails_gatekeeper_check`. It mirrors `Homebrew/homebrew-cask` but strips `disable!` and adds `postflight` quarantine removal. Migrates `darktable makemkv xld` and 619 others.

## Why

Homebrew `2025-09` enforced Gatekeeper (`spctl --assess`) and disabled all unsigned casks on `2026-09-01`. `622` casks (`darktable 5.6.1`, `makemkv 1.18.4`, `xld 20250302`, `alacritty`, `chromium`, `wine-stable`...) show:

```
Warning: Not upgrading darktable, it is disabled because it does not pass the macOS Gatekeeper check!
```

Upstream is truly unsigned — bumping `version` alone cannot fix without Apple Developer ID + notarization (`$99/yr`). This tap keeps them installable in a third-party tap (allowed) and auto-runs `xattr -r -d com.apple.quarantine` so `brew install` works like before.

Inspired by `SoftwareRat/homebrew-unsigned-tap` and `JosephAlton/homebrew-other-cask-tap`, but fully automated (622 casks, nightly sync, `brew audit` passing).

## Quickstart

```bash
brew tap thedavidweng/unsigned-tap
brew install --cask thedavidweng/unsigned-tap/darktable
# or short after tap
brew install --cask darktable
brew update && brew upgrade --cask --greedy
```

## One-Click Migrate from Official Disabled

If you have `darktable/makemkv/xld` installed from `homebrew/cask` (now `disabled`):

```bash
# 1. Tap
brew tap thedavidweng/unsigned-tap

# 2. One-liner: reinstall all your installed disabled casks from this tap (auto-updating)
curl -fsSL https://raw.githubusercontent.com/thedavidweng/homebrew-unsigned-tap/main/scripts/migrate.sh | bash

# 3. Verify
brew info --cask darktable # should show From: thedavidweng/unsigned-tap
brew upgrade --cask --greedy --dry-run
```

Manual per-cask:

```bash
brew reinstall --cask thedavidweng/unsigned-tap/darktable
brew reinstall --cask thedavidweng/unsigned-tap/makemkv
brew reinstall --cask thedavidweng/unsigned-tap/xld
```

## All 622 Casks

```bash
brew search thedavidweng/unsigned-tap/
ls $(brew --repo thedavidweng/unsigned-tap)/Casks | wc -l # 622
```

Popular: `alacritty`, `chromium`, `darktable`, `gstreamer-runtime`, `makemkv`, `qbittorrent`, `wine-stable`, `xld`, `zenmap`... Full list in [`Casks/`](Casks).

## How Updates Work

* **Source**: nightly `scripts/sync_disabled_casks.py` clones `Homebrew/homebrew-cask`, finds `Casks/**/*.rb` with `fails_gatekeeper_check` (622), strips `disable!` + deprecated `verified:`, injects:

```ruby
postflight do
  system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
end
```

* **Version tracking**: keeps upstream `url`/`livecheck`; `brew livecheck --tap thedavidweng/unsigned-tap` + `brew bump-cask-pr` bumps to latest. No frozen 2026-09-01 snapshot.
* **CI**: `.github/workflows/audit.yml` runs `brew audit --cask --strict` and `brew style`.

## Security Note

`postflight` bypasses Gatekeeper quarantine — you run unsigned code. This tap is a drop-in restore, not an endorsement. Check upstream (`Casks/*.rb` → `homepage`), use at your own risk. Official signing/notarization remains the proper fix.

## Alternatives

* Manual: download from upstream + `xattr -d com.apple.quarantine /Applications/App.app` + `System Settings → Privacy & Security → Open Anyway`
* Wait for upstream signing (e.g., `darktable-org/darktable#20572`)

## Contributing

PRs welcome for casks newly disabled in `homebrew/cask`. Run locally:

```bash
python3 scripts/sync_disabled_casks.py
brew tap thedavidweng/unsigned-tap /path/to/homebrew-unsigned-tap
brew audit --cask --strict thedavidweng/unsigned-tap/<cask>
brew style --fix Casks/<cask>.rb
```

## License

BSD-2-Clause, see [LICENSE](LICENSE).
