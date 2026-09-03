#!/usr/bin/env python3
"""
Sync disabled casks (fails_gatekeeper_check) from Homebrew/homebrew-cask
into this tap, stripping disable! and injecting quarantine removal.
"""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC_CASK_DIR = pathlib.Path(__import__("os").environ.get("SRC_CASK_DIR", str(pathlib.Path.home() / "homebrew-cask" / "Casks")))
DEST_CASK_DIR = ROOT / "Casks"

# Generic quarantine stripping postflight - covers app/pkg/binary
QUARANTINE_LINE = '    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s], must_succeed: false'
POSTFLIGHT_BLOCK = f"""  postflight do
{QUARANTINE_LINE}
  end
"""

# postflight must come before these (per RuboCop Cask stanza order):
# postflight < uninstall_preflight(_steps) < uninstall_postflight(_steps)
#   < uninstall < zap < caveats
# NOTE: include *_steps variants (new DSL); preflight(_steps) comes *before*
# postflight so must NOT be listed here.
POSTFLIGHT_FOLLOWERS = (
    "uninstall_preflight_steps",
    "uninstall_preflight",
    "uninstall_postflight_steps",
    "uninstall_postflight",
    "uninstall",
    "zap",
    "caveats",
)

# Upstream disabled casks are exempt from `desc`, but `brew audit --strict`
# requires it once re-enabled. Fallbacks for currently-missing tokens
# (keep alphabetical; must pass Cask/Desc: capital, no article, no name
# prefix, no platform, no trailing period, <80 chars).
MANUAL_DESC = {
    "blheli-configurator": "Configure BLHeli electronic speed controllers",
    "cmd-eikana": "Switch Japanese input mode with Command key",
    "dyn-updater": "Automatic dynamic DNS update client",
    "helium": "Backup Android devices to computer",
    "majsoul-plus": "Play Mahjong Soul in dedicated client",
    "material-colors": "Browse Material Design color palettes",
    "mqtt-explorer": "Visual client for MQTT brokers",
    "switchkey": "Keyboard layout switcher",
    "teeworlds": "Retro multiplayer shooter game",
    "transmission-remote-gui": "Remote control for Transmission downloads",
    "vagrant-manager": "Manage Vagrant development environments",
}


def _normalize(text: str) -> str:
    # Collapse 2+ blank lines to a single blank line.
    text = re.sub(r"\n{3,}", "\n\n", text)
    # No blank line immediately before any `end` (EmptyLinesAroundBlockBody).
    # Covers trailing blank inside on_* blocks left by disable! removal and
    # blank lines between consecutive `end`s.
    text = re.sub(r"\n\n+([ \t]*end\b)", r"\n\1", text)
    # No blank line immediately after any `do` (block body beginning).
    # Covers leading blank inside on_* blocks when disable! was first line.
    text = re.sub(r"(\bdo\n)\n+", r"\1", text)
    # `# No zap stanza required` must be in its own group separated by blanks
    # (StanzaGrouping). Upstream omits the preceding blank when no postflight
    # follows; once we inject postflight after the comment it becomes required.
    text = re.sub(r"([^\n])\n(  # No zap)", r"\1\n\n\2", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    if not text.endswith("\n"):
        text += "\n"
    return text


def transform_content(text: str) -> str:
    lines = text.splitlines()
    # Remove disable! lines with fails_gatekeeper_check
    # (may be top-level or inside on_* conditional blocks)
    filtered = []
    for line in lines:
        if "disable!" in line and "fails_gatekeeper_check" in line:
            continue
        filtered.append(line)
    text = "\n".join(filtered)

    # Drop conditional blocks left empty by the removal above, e.g.:
    #   on_intel do
    #   end
    #   on_sequoia :or_older do
    #   end
    # Keep blocks that still contain version/url/caveats (e.g. mysqlworkbench).
    text = re.sub(r"\n[ \t]*on_\w+[^\n]*\bdo\s*end", "", text)

    # Strip deprecated `verified:` param (brew audit now flags it)
    # Handles `, verified: "..."` either on same line or next line
    text = re.sub(r',\s*\n\s*verified:\s*"[^"]+"', '', text)
    text = re.sub(r',\s*verified:\s*"[^"]+"', '', text)
    text = re.sub(r',\s*\n\s*verified:\s*\'[^\']+\'', '', text)
    text = re.sub(r',\s*verified:\s*\'[^\']+\'', '', text)

    # Ensure `desc` exists (strict audit requires it; disabled upstream may omit).
    # Insert after last `name` stanza to respect stanza order (url, name, desc, homepage).
    if not re.search(r"^  desc ", text, re.M):
        m_tok = re.search(r'^cask "([^"]+)"', text, re.M)
        token = m_tok.group(1) if m_tok else ""
        fallback = MANUAL_DESC.get(token)
        if fallback is None:
            fallback = f"Unofficial restore of {token}" if token else "Unofficial restored app"
            print(f"warning: {token or '<unknown>'} missing desc, using generic fallback", file=sys.stderr)
        name_matches = list(re.finditer(r"^  name .+$", text, re.M))
        if name_matches:
            ins = name_matches[-1].end()
            text = text[:ins] + f'\n  desc "{fallback}"' + text[ins:]
        else:
            m_url = re.search(r"^  url .+$", text, re.M)
            if m_url:
                ins = m_url.end()
                text = text[:ins] + f'\n  desc "{fallback}"' + text[ins:]

    # If already has quarantine handling, just normalize whitespace (idempotent)
    if "com.apple.quarantine" in text or "remove_quarantine" in text:
        return _normalize(text)

    # If upstream already has a postflight (without quarantine), merge into it
    # instead of adding a second block (audit allows only a single postflight).
    if re.search(r"^  postflight do\b", text, re.M):
        merged = re.sub(
            r"(^  postflight do\n)(.*?)(\n  end)",
            lambda m: m.group(1) + m.group(2).rstrip() + "\n" + QUARANTINE_LINE + m.group(3),
            text,
            count=1,
            flags=re.M | re.S,
        )
        return _normalize(merged)

    # Inject new postflight respecting stanza order:
    # postflight < uninstall_preflight < uninstall_postflight < uninstall < zap < caveats
    follower_pat = re.compile(
        r"^  (?:"
        + "|".join(POSTFLIGHT_FOLLOWERS)
        + r")\b",
        re.M,
    )
    m = follower_pat.search(text)
    if m:
        before = text[: m.start()].rstrip()
        after = text[m.start() :].lstrip("\n")
        injected = before + "\n\n" + POSTFLIGHT_BLOCK.rstrip() + "\n\n" + after
        return _normalize(injected)
    parts = text.rsplit("\nend", 1)
    if len(parts) == 2:
        before, after = parts
        injected = before.rstrip() + "\n\n" + POSTFLIGHT_BLOCK.rstrip() + "\nend" + after
        return _normalize(injected)
    else:
        return _normalize(text.rstrip() + "\n\n" + POSTFLIGHT_BLOCK + "\n")

def sync_all(limit_files=None, dry_run=False):
    src_files = sorted(SRC_CASK_DIR.rglob("*.rb"))
    disabled = []
    for p in src_files:
        try:
            txt = p.read_text()
        except: continue
        if "fails_gatekeeper_check" in txt:
            disabled.append(p)

    print(f"Found {len(disabled)} disabled casks (fails_gatekeeper_check)")

    if limit_files is not None:
        # filter to only specified tokens
        wanted = set(limit_files)
        disabled = [p for p in disabled if p.stem in wanted]
        print(f"Filtered to {len(disabled)} requested: {wanted}")

    DEST_CASK_DIR.mkdir(parents=True, exist_ok=True)

    for src in disabled:
        dest = DEST_CASK_DIR / src.name
        text = src.read_text()
        new_text = transform_content(text)
        if dry_run:
            print(f"[dry-run] would write {dest.name}")
        else:
            dest.write_text(new_text)
            print(f"Wrote {dest}")

    print(f"Done. Dest count: {len(list(DEST_CASK_DIR.glob('*.rb')))}")

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", nargs="*", help="only sync these tokens")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    sync_all(limit_files=args.limit, dry_run=args.dry_run)
