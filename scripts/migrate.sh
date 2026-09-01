#!/usr/bin/env bash
# migrate.sh — Homebrew-style one-click migrate for thedavidweng/unsigned-tap
# Restores 618 Gatekeeper-disabled casks (fails_gatekeeper_check) with quarantine removal.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/thedavidweng/homebrew-unsigned-tap/main/scripts/migrate.sh | bash
#   bash scripts/migrate.sh              # interactive (default)
#   bash scripts/migrate.sh --yes        # migrate all without prompt
#   bash scripts/migrate.sh --dry-run    # preview only
#   bash scripts/migrate.sh --list       # list only
#   bash scripts/migrate.sh --interactive# per-cask y/N
set -euo pipefail

TAP="thedavidweng/unsigned-tap"
TAP_REPO="/opt/homebrew/Library/Taps/thedavidweng/homebrew-unsigned-tap"
CASK_DIR_FALLBACK="/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks"

YES=0
INTERACTIVE=0
DRY_RUN=0
LIST_ONLY=0

for arg in "$@"; do
  case "$arg" in
    -y|--yes) YES=1 ;;
    -i|--interactive) INTERACTIVE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    --list) LIST_ONLY=1 ;;
    -h|--help) echo "Usage: $0 [--yes] [--interactive] [--dry-run] [--list]"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# Ensure tap
if ! brew tap | grep -q "thedavidweng/unsigned-tap"; then
  echo "==> Tapping $TAP ..."
  brew tap "$TAP"
else
  # keep tap fresh for version comparison
  brew tap --repair >/dev/null 2>&1 || true
fi

# Find disabled tokens (single source of truth: Homebrew/homebrew-cask)
CASK_DIR="$HOME/homebrew-cask/Casks"
[ -d "$CASK_DIR" ] || CASK_DIR="$CASK_DIR_FALLBACK"
DISABLED_TOKENS=""
if [ -d "$CASK_DIR" ]; then
  DISABLED_TOKENS=$(grep -l "fails_gatekeeper_check" "$CASK_DIR"/*/*.rb 2>/dev/null | xargs -I{} basename {} .rb | tr '\n' ' ' || true)
fi
if [ -z "$DISABLED_TOKENS" ]; then
  DISABLED_TOKENS=$(grep -r "fails_gatekeeper_check" /opt/homebrew/Library/Taps --include="*.rb" 2>/dev/null | cut -d: -f1 | xargs -I{} basename {} .rb | tr '\n' ' ' || true)
fi

INSTALLED=$(brew list --cask 2>/dev/null || true)
if [ -z "$INSTALLED" ]; then
  echo "No casks installed."
  exit 0
fi

# Build migration list with version info (bash 3.2 compatible, no associative arrays)
# Only migrate if installed from homebrew/cask (skip third-party taps sharing same token)
TO_MIGRATE=()
for cask in $INSTALLED; do
  if echo " $DISABLED_TOKENS " | grep -q " $cask "; then
    receipt="/opt/homebrew/Caskroom/$cask/.metadata/INSTALL_RECEIPT.json"
    installed_tap=""
    if [ -f "$receipt" ]; then
      installed_tap=$(python3 -c "import json; print(json.load(open('$receipt')).get('source',{}).get('tap',''))" 2>/dev/null || echo "")
    fi
    if [ -z "$installed_tap" ] || [ "$installed_tap" = "homebrew/cask" ]; then
      TO_MIGRATE+=("$cask")
    else
      echo "  Note: skipping $cask (third-party tap, not homebrew/cask)" >&2
    fi
  fi
done

if [ ${#TO_MIGRATE[@]} -eq 0 ]; then
  echo "No installed disabled casks found."
  echo "You have ${#INSTALLED} casks, none match the 618 disabled (fails_gatekeeper_check)."
  echo "Install any directly: brew install --cask $TAP/darktable"
  exit 0
fi

# Homebrew-style table
echo ""
echo "==> Found ${#TO_MIGRATE[@]} installed cask(s) disabled in homebrew/cask (will restore via $TAP):"
printf "  %-22s %-14s %-14s %s\n" "Cask" "Installed" "Tap" "Notes"
printf "  %-22s %-14s %-14s %s\n" "----------------------" "--------------" "--------------" "-----"
for cask in "${TO_MIGRATE[@]}"; do
  iver=$(brew list --cask --versions "$cask" 2>/dev/null | awk '{print $2}' || echo "?")
  tver=$(brew info --cask "$TAP/$cask" --json=v2 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['casks'][0]['version'] if d['casks'] else '?')" 2>/dev/null || echo "?")
  note=""
  if [ "$iver" != "$tver" ] && [ "$tver" != "?" ]; then
    note="(tap differs)"
  fi
  printf "  %-22s %-14s %-14s %s\n" "$cask" "$iver" "$tver" "$note"
done
echo ""

if [ "$LIST_ONLY" -eq 1 ]; then
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "(dry-run) Would migrate: ${TO_MIGRATE[*]}"
  echo "Run without --dry-run to proceed."
  exit 0
fi

# Prompt (Homebrew style: y/i/N)
if [ "$YES" -eq 0 ] && [ "$INTERACTIVE" -eq 0 ]; then
  printf "Migrate %d cask(s)? [y/i/N] " "${#TO_MIGRATE[@]}"
  read -r ans
  case "$ans" in
    y|Y|yes) YES=1 ;;
    i|I) INTERACTIVE=1 ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

MIGRATED=0
FAILED=0
SKIPPED=0

for cask in "${TO_MIGRATE[@]}"; do
  do_migrate=0
  if [ "$YES" -eq 1 ]; then
    do_migrate=1
  elif [ "$INTERACTIVE" -eq 1 ]; then
    iver=$(brew list --cask --versions "$cask" 2>/dev/null | awk '{print $2}' || echo "?")
    tver=$(brew info --cask "$TAP/$cask" --json=v2 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['casks'][0]['version'] if d['casks'] else '?')" 2>/dev/null || echo "?")
    printf "Migrate %s %s -> %s ? [y/N] " "$cask" "$iver" "$tver"
    read -r a
    case "$a" in
      y|Y|yes) do_migrate=1 ;;
      *) echo "  Skipped $cask"; SKIPPED=$((SKIPPED+1)); continue ;;
    esac
  fi

  if [ "$do_migrate" -eq 1 ]; then
    echo "==> Reinstalling $cask from $TAP ..."
    if brew reinstall --cask "$TAP/$cask"; then
      echo "✔ $cask migrated"
      MIGRATED=$((MIGRATED+1))
    else
      echo "✖ $cask failed — try manually: brew install --cask $TAP/$cask --force" >&2
      FAILED=$((FAILED+1))
    fi
  fi
done

echo ""
echo "==> Done: $MIGRATED migrated, $SKIPPED skipped, $FAILED failed."
echo "Verify:"
echo "  brew info --cask darktable | grep -E 'From|Poured'"
echo "  brew upgrade --cask --greedy --dry-run"
