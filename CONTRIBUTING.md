# Contributing

:+1::tada: Thanks for taking the time to contribute! This tap mirrors `Homebrew/homebrew-cask` for unsigned casks and follows the same guidelines.

* [Updating a Cask](#updating-a-cask)
* [Adding a Disabled Cask](#adding-a-disabled-cask)
* [Style Guide](#style-guide)

## Updating a Cask

Most casks are auto-synced from `Homebrew/homebrew-cask` (`fails_gatekeeper_check`). For manual bumps:

```bash
brew bump --open-pr <cask> --tap thedavidweng/unsigned-tap
# or
brew livecheck --tap thedavidweng/unsigned-tap <cask>
```

## Adding a Disabled Cask

Only casks disabled in `Homebrew/homebrew-cask` with `because: :fails_gatekeeper_check` are accepted. Run:

```bash
python3 scripts/sync_disabled_casks.py --limit <cask>
brew audit --cask --strict thedavidweng/unsigned-tap/<cask>
brew style --fix Casks/<cask>.rb
```

One cask per PR, minimal diffs.

## Style Guide

* Two spaces, no tabs.
* Stanza order per [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook#stanza-order).
* Test before PR:

```bash
brew audit --cask --online <cask>
brew style --fix <cask>
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask <cask>
brew uninstall --cask <cask>
```

## Reporting Bugs

See [README#reporting-bugs](README.md) and use the Bug Report template.
