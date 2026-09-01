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
POSTFLIGHT_BLOCK = """  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end
"""

def transform_content(text: str) -> str:
    lines = text.splitlines()
    # Remove disable! lines with fails_gatekeeper_check
    filtered = []
    for line in lines:
        if "disable!" in line and "fails_gatekeeper_check" in line:
            continue
        filtered.append(line)
    text = "\n".join(filtered)

    # Strip deprecated `verified:` param (brew audit now flags it)
    # Handles `, verified: "..."` either on same line or next line
    text = re.sub(r',\s*\n\s*verified:\s*"[^"]+"', '', text)
    text = re.sub(r',\s*verified:\s*"[^"]+"', '', text)
    text = re.sub(r',\s*\n\s*verified:\s*\'[^\']+\'', '', text)
    text = re.sub(r',\s*verified:\s*\'[^\']+\'', '', text)

    # If already has quarantine handling, keep as is (don't duplicate)
    if "com.apple.quarantine" in text or "remove_quarantine" in text:
        # still ensure disable! removed
        if not text.endswith("\n"):
            text += "\n"
        return text

    # Inject postflight respecting stanza order (postflight before zap/caveats)
    # Prefer before `zap` if present, else before final `end`
    if "\n  zap" in text:
        parts = text.split("\n  zap", 1)
        before, after = parts
        injected = before.rstrip() + "\n\n" + POSTFLIGHT_BLOCK.rstrip() + "\n\n  zap" + after
        if not injected.endswith("\n"):
            injected += "\n"
        return injected
    parts = text.rsplit("\nend", 1)
    if len(parts) == 2:
        before, after = parts
        injected = before.rstrip() + "\n\n" + POSTFLIGHT_BLOCK.rstrip() + "\nend" + after
        if not injected.endswith("\n"):
            injected += "\n"
        return injected
    else:
        return text.rstrip() + "\n\n" + POSTFLIGHT_BLOCK + "\n"

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
