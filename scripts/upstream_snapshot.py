"""Build the upstream version snapshot for catch-up and radar.

Run from the daily sync job, which already holds the upstream checkout:
read-only file scan, no network, no brew. The snapshot lets autobump and
the radar consume upstream versions without cloning homebrew-cask again.

Reads:
  SRC_CASK_DIR  upstream Casks checkout
  SNAPSHOT_OUT  output path (default upstream-versions.json)

Writes {token: [version literals]} as JSON.
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import upstream_catchup


def main():
    src = os.environ.get("SRC_CASK_DIR", "")
    out = os.environ.get("SNAPSHOT_OUT", "upstream-versions.json")
    if not src or not Path(src).exists():
        raise SystemExit(f"upstream checkout missing: {src!r}")
    snapshot = upstream_catchup.snapshot_upstream(src)
    Path(out).write_text(json.dumps(snapshot, indent=2, sort_keys=True) + "\n")
    print(f"snapshot: {len(snapshot)} tokens -> {out}")


if __name__ == "__main__":
    main()
