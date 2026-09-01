<!-- One cask per PR, minimal diffs, aligned with Homebrew/homebrew-cask -->
After making any changes to a cask, verify:

- [ ] The submission is for a stable version or documented exception.
- [ ] `brew audit --cask --online <cask>` is error-free.
- [ ] `brew style --fix <cask>` reports no offenses.

If adding a new disabled cask (must be `fails_gatekeeper_check` in Homebrew/homebrew-cask):

- [ ] `brew audit --cask --new <cask>` worked successfully.
- [ ] `HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask <cask>` worked successfully.
- [ ] `brew uninstall --cask <cask>` worked successfully.

If AI-assisted:

- [ ] AI was used to assist and I have manually verified `zap` stanza paths.

---
