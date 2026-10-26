"""Bump candidates for casks that lag behind Homebrew/homebrew-cask unseen.

`brew livecheck` cannot flag every outdated cask: some casks have no
livecheck block on the runner's OS/arch channel, and some livecheck
strategies fail outright. Those casks would freeze at their imported version
forever. This script compares single-version casks against the upstream
checkout and emits explicit `--version=` bump rows for tokens where upstream
is strictly newer, so the normal `bump-cask-pr` machinery (download + audit)
can validate and open the PR.

Safety rules (fail-closed, never downgrade, never override intent):
- Only casks with exactly one double-quoted version literal on both sides.
  Anything arch- or OS-branched stays livecheck's job.
- Never touch casks whose livecheck skips: a skip encodes a deliberate pin
  (e.g. ntfstool pins the open-source 3.5.1 edition while upstream moved to
  a closed-source track). Adopting upstream's version there would be wrong.
- Never touch `version :latest`.
- Only fire when upstream is strictly newer under Homebrew's own `Version`
  comparison (reused via `brew ruby`, not reimplemented).
- Tokens already flagged by livecheck or with an open same-repo bump PR are
  excluded; they are handled by the normal plan/refresh path.

Reads:
  SNAPSHOT_JSON  {token: [version literals]} built by upstream_snapshot.py
                 from the daily sync checkout (preferred: no clone needed)
  SRC_CASK_DIR   upstream Casks checkout (fallback when no snapshot; default
                 ~/homebrew-cask/Casks). A cask deleted upstream simply has no
                 entry and is skipped — tracking a deleted cask is impossible
                 by any method; livecheck remains its only updater.
  TAP_CASK_DIR   this tap's Casks dir (default <repo>/Casks)
  EXCLUDE_TOKENS space-separated tokens livecheck already flagged
  ONLY_TOKENS    when set, restrict to these tokens (manual dispatch scope)
  OPEN_PRS_JSON  path to slurped `gh api .../pulls` JSON (open PRs)

Prints TSV rows: token<TAB>version<TAB>--version=<upstream version>
"""
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC_CASK_DIR = Path(os.environ.get("SRC_CASK_DIR", str(Path.home() / "homebrew-cask" / "Casks")))
TAP_CASK_DIR = Path(os.environ.get("TAP_CASK_DIR", str(ROOT / "Casks")))

VERSION_LIT = re.compile(r'^[ \t]*version\s+"([^"]+)"', re.M)
LIVECHECK_BLOCK = re.compile(r"^[ \t]*livecheck(?:\s+do|\s*$)(.*?)^[ \t]*end", re.M | re.S)
SKIP_LINE = re.compile(r"^[ \t]*skip\b", re.M)


def version_literals(text):
    return VERSION_LIT.findall(text)


def has_livecheck_skip(text):
    return any(SKIP_LINE.search(block) for block in LIVECHECK_BLOCK.findall(text))


def open_bump_refs(pages, repo):
    """Head branches of open same-repo bump PRs (refresh path owns them)."""
    refs = set()
    for page in pages:
        for pr in page:
            try:
                head = pr["head"]
                if pr["user"]["login"] not in ("github-actions[bot]", repo.split("/", 1)[0]):
                    continue
                if head["repo"]["full_name"] != repo:
                    continue
                ref = head["ref"]
            except (KeyError, TypeError):
                continue
            if ref.startswith("bump-"):
                refs.add(ref)
    return refs


def snapshot_upstream(src_dir):
    """Map token -> version literals for an upstream Casks checkout.

    Upstream groups casks in per-letter subdirectories; index by basename.
    """
    snapshot = {}
    for path in Path(src_dir).rglob("*.rb"):
        snapshot[path.stem] = version_literals(path.read_text())
    return snapshot


def load_snapshot(path):
    return {token: list(lits) for token, lits in json.loads(Path(path).read_text()).items()}


def candidates(tap_dir, upstream, exclude, only, open_refs):
    """Compare tap files against {token: [upstream version literals]}."""
    pairs = []
    for dest in sorted(Path(tap_dir).glob("*.rb")):
        token = dest.stem
        if only and token not in only:
            continue
        if token in exclude:
            continue
        if any(ref.startswith(f"bump-{token}-") for ref in open_refs):
            continue
        if token not in upstream:
            # Deleted upstream: nothing to compare against. Livecheck remains
            # the only updater; the radar issue reports these for human review.
            continue
        text = dest.read_text()
        ours = version_literals(text)
        theirs = upstream[token]
        if len(ours) != 1 or len(theirs) != 1 or ours[0] == theirs[0]:
            continue
        if has_livecheck_skip(text):
            print(f"note: {token} pins its version via livecheck skip; not adopting upstream {theirs[0]}",
                  file=sys.stderr)
            continue
        pairs.append((token, ours[0], theirs[0]))
    return pairs


def upstream_newer(pairs):
    """Filter to pairs where upstream is strictly newer (Homebrew semantics)."""
    if not pairs:
        return []
    payload = json.dumps(pairs)
    script = (
        'require "json"; require "version";'
        ' JSON.parse(ARGV[0]).each do |token, ours, theirs|;'
        ' begin; cmp = Version.new(ours) <=> Version.new(theirs); rescue; cmp = nil; end;'
        ' puts [token, cmp.nil? ? "ERR" : (cmp < 0 ? "NEWER" : "OTHER")].join("\t"); end'
    )
    out = subprocess.check_output(["brew", "ruby", "-e", script, "--", payload], text=True)
    newer = {line.split("\t")[0] for line in out.splitlines() if line.endswith("\tNEWER")}
    return [(token, theirs) for token, _ours, theirs in pairs if token in newer]


def main():
    exclude = set(os.environ.get("EXCLUDE_TOKENS", "").split())
    only_raw = os.environ.get("ONLY_TOKENS", "").strip()
    only = set(only_raw.split()) if only_raw else set()
    prs_path = os.environ.get("OPEN_PRS_JSON", "")
    open_refs = set()
    if prs_path and Path(prs_path).exists():
        pages = json.loads(Path(prs_path).read_text())
        open_refs = open_bump_refs(pages, os.environ.get("GITHUB_REPOSITORY", ""))
    snapshot_path = os.environ.get("SNAPSHOT_JSON", "")
    if snapshot_path and Path(snapshot_path).exists():
        upstream = load_snapshot(snapshot_path)
    else:
        upstream = snapshot_upstream(SRC_CASK_DIR)
    pairs = candidates(TAP_CASK_DIR, upstream, exclude, only, open_refs)
    for token, version in upstream_newer(pairs):
        print(f"{token}\t{version}\t--version={version}")


if __name__ == "__main__":
    main()
