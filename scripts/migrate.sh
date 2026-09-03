#!/usr/bin/env bash
# migrate.sh: Homebrew-style one-click migration for thedavidweng/unsigned-tap
# Restores all Gatekeeper-disabled casks (fails_gatekeeper_check) with automatic quarantine removal.
#
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thedavidweng/homebrew-unsigned-tap/main/scripts/migrate.sh)"
#   bash scripts/migrate.sh              # interactive (default)
#   bash scripts/migrate.sh --yes        # migrate all without prompt (or NONINTERACTIVE=1)
#   bash scripts/migrate.sh --dry-run    # preview only
#   bash scripts/migrate.sh --list       # list only
#   bash scripts/migrate.sh --interactive# per-cask y/N
set -euo pipefail

TAP="thedavidweng/unsigned-tap"

# String formatting helpers (aligned with Homebrew official installer / Library/Homebrew/utils/formatter.sh)
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_yellow="$(tty_mkbold 33)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$*"
}

warn() {
  printf "${tty_yellow}Warning${tty_reset}: %s\n" "$*" >&2
}

onoe() {
  printf "${tty_red}Error${tty_reset}: %s\n" "$*" >&2
}

abort() {
  onoe "$*"
  exit 1
}

# Environment validation
OS_NAME="$(uname)"
if [[ "${OS_NAME}" != "Darwin" ]]
then
  abort "Homebrew unsigned tap is designed for macOS (Darwin) only."
fi

if ! command -v brew >/dev/null 2>&1
then
  onoe "Homebrew (brew) is not found in your PATH!"
  echo ""
  ohai "Next steps:"
  echo "- Follow official installation instructions at https://brew.sh:"
  echo "    ${tty_bold}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${tty_reset}"
  exit 1
fi

YES=0
INTERACTIVE=0
DRY_RUN=0
LIST_ONLY=0

# Support Homebrew official non-interactive environment flags
if [[ -n "${NONINTERACTIVE-}" ]] || [[ -n "${CI-}" ]]
then
  YES=1
fi

for arg in "$@"
do
  case "${arg}" in
    -y | --yes) YES=1 ;;
    -i | --interactive) INTERACTIVE=1 ;;
    -n | --dry-run) DRY_RUN=1 ;;
    --list) LIST_ONLY=1 ;;
    -h | --help)
      cat <<EOS
Homebrew Unsigned Tap Migration Script
Usage: [NONINTERACTIVE=1] migrate.sh [options]
    -y, --yes          Migrate all matching casks without prompting
    -i, --interactive  Prompt for approval on each cask individually
    -n, --dry-run      Preview which casks would be migrated without reinstalling
    --list             Display matching casks and exit
    -h, --help         Display this help message
EOS
      exit 0
      ;;
    *)
      onoe "Unknown option: ${arg}"
      echo "Run '$0 --help' for usage." >&2
      exit 1
      ;;
  esac
done

# Ensure tap
if ! brew tap | grep -q "^${TAP}$"
then
  ohai "Tapping ${TAP} ..."
  brew tap "${TAP}"
fi

TAP_REPO=$(brew --repo "${TAP}")

INSTALLED=$(brew list --cask 2>/dev/null || true)
if [[ -z "${INSTALLED}" ]]
then
  ohai "No casks installed on your system."
  echo "You have 0 casks installed."
  echo ""
  ohai "Next steps:"
  echo "- Install any restored cask directly from this tap:"
  echo "    ${tty_bold}brew install --cask ${TAP}/<cask-name>${tty_reset}"
  echo "- Search available casks:"
  echo "    ${tty_bold}brew search ${TAP}/${tty_reset}"
  exit 0
fi

# Build migration list (only casks present in this tap and installed from homebrew/cask)
TO_MIGRATE=()
SKIPPED_CASKS=()

for cask in ${INSTALLED}
do
  if [[ -f "${TAP_REPO}/Casks/${cask}.rb" ]]
  then
    receipt="/opt/homebrew/Caskroom/${cask}/.metadata/INSTALL_RECEIPT.json"
    installed_tap=""
    if [[ -f "${receipt}" ]]
    then
      installed_tap=$(python3 -c "import json; print(json.load(open('${receipt}')).get('source',{}).get('tap',''))" 2>/dev/null || echo "")
    fi
    if [[ "${installed_tap}" = "${TAP}" ]]
    then
      continue
    fi
    if [[ -z "${installed_tap}" ]] || [[ "${installed_tap}" = "homebrew/cask" ]]
    then
      TO_MIGRATE+=("${cask}")
    else
      SKIPPED_CASKS+=("${cask}:${installed_tap}")
    fi
  fi
done

# Display any skipped third-party casks
if [[ ${#SKIPPED_CASKS[@]} -gt 0 ]]
then
  for item in "${SKIPPED_CASKS[@]}"
  do
    cask_token="${item%%:*}"
    cask_source="${item#*:}"
    warn "Skipping '${cask_token}' because it was installed from '${cask_source}' (not homebrew/cask)."
  done
  echo "  (To migrate these anyway, run: ${tty_bold}brew reinstall --cask ${TAP}/<cask-name>${tty_reset})" >&2
  echo "" >&2
fi

if [[ ${#TO_MIGRATE[@]} -eq 0 ]]
then
  ohai "No disabled casks found needing migration."
  echo "All matching casks on your system are already up-to-date and migrated to ${TAP}."
  echo ""
  ohai "Next steps:"
  echo "- To upgrade all your installed casks (including unsigned casks):"
  echo "    ${tty_bold}brew upgrade --cask --greedy${tty_reset}"
  echo "- To install additional restored casks:"
  echo "    ${tty_bold}brew install --cask ${TAP}/<cask-name>${tty_reset}"
  echo "- To verify your Homebrew installation status:"
  echo "    ${tty_bold}brew doctor${tty_reset}"
  exit 0
fi

# Homebrew-style table
ohai "Found ${#TO_MIGRATE[@]} installed cask(s) disabled in homebrew/cask (will restore via ${TAP}):"
printf "  ${tty_bold}%-22s %-14s %-14s %s${tty_reset}\n" "Cask" "Installed" "Tap" "Notes"
printf "  %-22s %-14s %-14s %s\n" "----------------------" "--------------" "--------------" "-----"
for cask in "${TO_MIGRATE[@]}"
do
  iver=$(brew list --cask --versions "${cask}" 2>/dev/null | awk '{print $2}' || echo "?")
  tver=$(grep -E '^[[:space:]]*version[[:space:]]+' "${TAP_REPO}/Casks/${cask}.rb" 2>/dev/null | sed -E 's/^[[:space:]]*version[[:space:]]+//; s/["'\'']//g' | head -n 1 || echo "?")
  [[ -z "${tver}" ]] && tver="?"
  note=""
  if [[ "${iver}" != "${tver}" ]] && [[ "${tver}" != "?" ]]
  then
    note="(tap differs)"
  fi
  printf "  %-22s %-14s %-14s %s\n" "${cask}" "${iver}" "${tver}" "${note}"
done
echo ""

if [[ "${LIST_ONLY}" -eq 1 ]]
then
  exit 0
fi

if [[ "${DRY_RUN}" -eq 1 ]]
then
  ohai "Dry-run complete."
  echo "Would migrate: ${tty_bold}${TO_MIGRATE[*]}${tty_reset}"
  echo ""
  ohai "Next steps:"
  echo "- Run without --dry-run to proceed with migration:"
  echo "    ${tty_bold}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/thedavidweng/homebrew-unsigned-tap/main/scripts/migrate.sh)\"${tty_reset}"
  exit 0
fi

# Prompt (Homebrew style: y/i/N)
if [[ "${YES}" -eq 0 ]] && [[ "${INTERACTIVE}" -eq 0 ]]
then
  printf "${tty_bold}Migrate %d cask(s)? [y/i/N]${tty_reset} " "${#TO_MIGRATE[@]}"
  read -r ans </dev/tty 2>/dev/null || read -r ans || ans=""
  case "${ans}" in
    y | Y | yes) YES=1 ;;
    i | I) INTERACTIVE=1 ;;
    *)
      warn "Aborted by user. No changes were made."
      exit 0
      ;;
  esac
fi

MIGRATED=0
FAILED=0
SKIPPED=0
FAILED_CASKS=()

for cask in "${TO_MIGRATE[@]}"
do
  do_migrate=0
  if [[ "${YES}" -eq 1 ]]
  then
    do_migrate=1
  elif [[ "${INTERACTIVE}" -eq 1 ]]
  then
    iver=$(brew list --cask --versions "${cask}" 2>/dev/null | awk '{print $2}' || echo "?")
    tver=$(grep -E '^[[:space:]]*version[[:space:]]+' "${TAP_REPO}/Casks/${cask}.rb" 2>/dev/null | sed -E 's/^[[:space:]]*version[[:space:]]+//; s/["'\'']//g' | head -n 1 || echo "?")
    printf "${tty_bold}Migrate %s (%s -> %s)? [y/N]${tty_reset} " "${cask}" "${iver}" "${tver}"
    read -r a </dev/tty 2>/dev/null || read -r a || a=""
    case "${a}" in
      y | Y | yes) do_migrate=1 ;;
      *)
        warn "Skipped ${cask}"
        SKIPPED=$((SKIPPED + 1))
        continue
        ;;
    esac
  fi

  if [[ "${do_migrate}" -eq 1 ]]
  then
    echo ""
    ohai "Reinstalling ${cask} from ${TAP} ..."
    if brew reinstall --cask "${TAP}/${cask}"
    then
      printf "${tty_green}✔${tty_reset} ${tty_bold}%s${tty_reset} successfully migrated\n" "${cask}"
      MIGRATED=$((MIGRATED + 1))
    else
      printf "${tty_red}✘${tty_reset} ${tty_bold}%s${tty_reset} failed to reinstall\n" "${cask}" >&2
      FAILED_CASKS+=("${cask}")
      FAILED=$((FAILED + 1))
    fi
  fi
done

echo ""
if [[ "${FAILED}" -eq 0 ]]
then
  ohai "Migration successful! (${MIGRATED} migrated, ${SKIPPED} skipped, ${FAILED} failed)"
  echo ""
  ohai "Next steps:"
  echo "- Run brew upgrade to verify your casks upgrade smoothly:"
  echo "    ${tty_bold}brew upgrade --cask --greedy${tty_reset}"
  echo "- To inspect any migrated cask:"
  echo "    ${tty_bold}brew info --cask <cask-name>${tty_reset}"
  echo "- If you ever experience issues with installed applications:"
  echo "    ${tty_bold}brew doctor${tty_reset}"
else
  warn "Migration completed with errors: ${MIGRATED} migrated, ${SKIPPED} skipped, ${FAILED} failed."
  echo ""
  ohai "Next steps:"
  echo "- The following cask(s) failed during reinstall:"
  for f_cask in "${FAILED_CASKS[@]}"
  do
    echo "    - ${f_cask}"
  done
  echo "- Try reinstalling them manually with --force:"
  for f_cask in "${FAILED_CASKS[@]}"
  do
    echo "    ${tty_bold}brew reinstall --cask ${TAP}/${f_cask} --force${tty_reset}"
  done
  echo "- Check system dependencies and tap health by running:"
  echo "    ${tty_bold}brew doctor${tty_reset}"
fi
