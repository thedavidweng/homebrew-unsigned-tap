# homebrew-unsigned-tap

Restore and auto-update all macOS casks disabled by Homebrew (`fails_gatekeeper_check`). Removes Gatekeeper quarantine on install.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thedavidweng/homebrew-unsigned-tap/main/scripts/migrate.sh)"
```

[English](README.md) · [简体中文](README.zh-CN.md)

Run the command above to:
* Tap `thedavidweng/unsigned-tap`
* Reinstall your disabled casks (`darktable`, `makemkv`, `xld`, `chromium`, `alacritty`...)
* Clear quarantine so `brew upgrade --cask --greedy` works again

*(Options: `--dry-run` to preview, `--yes` to skip prompts, `--interactive` for per-cask approval)*

---

## Single Cask

```bash
brew tap thedavidweng/unsigned-tap
brew install --cask <cask-name>

# Or migrate an existing cask:
brew reinstall --cask thedavidweng/unsigned-tap/<cask-name>
```

## Why

Homebrew disables unsigned casks that fail macOS Gatekeeper checks:

```text
Warning: Not upgrading <cask>, it is disabled because it does not pass the macOS Gatekeeper check!
```

This tap keeps them installable, strips Gatekeeper quarantine on install (`xattr -d com.apple.quarantine`), and tracks upstream updates nightly.

## Popular Casks

`darktable` · `makemkv` · `xld` · `chromium` · `alacritty` · `qbittorrent` · `wine-stable` · `zenmap` · `gstreamer-runtime`

Search all casks:
```bash
brew search thedavidweng/unsigned-tap/
```

## Security

This tap strips the quarantine attribute on install. You are running unsigned code by design. Use at your own discretion.

## License

[BSD-2-Clause](LICENSE)
