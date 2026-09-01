#!/usr/bin/env bash
# migrate.sh — one-click migrate your installed disabled (fails_gatekeeper_check) casks to thedavidweng/unsigned-tap
set -euo pipefail

TAP="thedavidweng/unsigned-tap"
echo "==> Tapping $TAP ..."
brew tap "$TAP" >/dev/null 2>&1 || true

echo "==> Finding installed casks that are disabled in homebrew/cask (fails_gatekeeper_check) ..."
# Use homebrew/cask as source of truth for disabled list
CASK_DIR="${HOME}/homebrew-cask/Casks"
if [ ! -d "$CASK_DIR" ]; then
  CASK_DIR="/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks"
fi

# Build set of disabled tokens
DISABLED_TOKENS=$(grep -l "fails_gatekeeper_check" "$CASK_DIR"/*/*.rb 2>/dev/null | xargs -I{} basename {} .rb | tr '\n' ' ' || true)
if [ -z "$DISABLED_TOKENS" ]; then
  DISABLED_TOKENS=$(grep -r "fails_gatekeeper_check" /opt/homebrew/Library/Taps --include="*.rb" 2>/dev/null | cut -d: -f1 | xargs -I{} basename {} .rb | tr '\n' ' ' || true)
fi

INSTALLED=$(brew list --cask 2>/dev/null || true)
if [ -z "$INSTALLED" ]; then
  echo "No casks installed."
  exit 0
fi

TO_MIGRATE=()
for cask in $INSTALLED; do
  if echo " $DISABLED_TOKENS " | grep -q " $cask "; then
    TO_MIGRATE+=("$cask")
  fi
done

if [ ${#TO_MIGRATE[@]} -eq 0 ]; then
  echo "No installed disabled casks found. Nothing to migrate."
  echo "You can still install any of the 618 casks directly:"
  echo "  brew install --cask thedavidweng/unsigned-tap/darktable"
  exit 0
fi

echo "==> Will migrate ${#TO_MIGRATE[@]} casks: ${TO_MIGRATE[*]}"
for cask in "${TO_MIGRATE[@]}"; do
  echo "--- reinstalling $cask from $TAP ---"
  # reinstall from this tap (staged_path postflight will clear quarantine)
  if brew reinstall --cask "$TAP/$cask" 2>&1 | tail -n 20; then
    echo "✔ $cask migrated"
  else
    echo "✖ $cask failed — try: brew install --cask $TAP/$cask --force"
  fi
done

echo "==> Done. Verify:"
echo "  brew info --cask darktable | grep From"
echo "  brew upgrade --cask --greedy --dry-run"
