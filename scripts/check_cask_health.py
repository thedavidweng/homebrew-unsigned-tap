#!/usr/bin/env python3
"""
check_cask_health.py: Validate download availability for all casks in the tap.
Detects dead URLs (404, expired SSL, connection refused) to identify dead casks.

Usage:
  python3 scripts/check_cask_health.py             # report status, exit 1 if dead found
  python3 scripts/check_cask_health.py --delete    # automatically remove dead casks
"""

import argparse
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CASKS_DIR = ROOT / "Casks"

def get_all_cask_urls():
    ruby_script = """
    tap = Tap.fetch("thedavidweng/unsigned-tap")
    urls = tap.cask_files.map do |f|
      c = Cask::CaskLoader.load(f)
      [c.token, c.url.to_s]
    end.to_h
    require "json"
    puts JSON.generate(urls)
    """
    res = subprocess.run(["brew", "ruby", "-e", ruby_script], capture_output=True, text=True, check=True)
    return json.loads(res.stdout)

def check_url(token, url):
    cmd = [
        "curl", "-s", "-L", "-o", "/dev/null",
        "-A", "Homebrew/cask",
        "--max-time", "12",
        "--range", "0-1024",
        "-w", "%{http_code}",
        url
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        code = proc.stdout.strip()
        return token, url, code, ""
    except subprocess.TimeoutExpired:
        return token, url, "TIMEOUT", "Timeout after 15s"
    except Exception as e:
        return token, url, "ERR", str(e)

def main():
    parser = argparse.ArgumentParser(description="Check cask download health")
    parser.add_argument("--delete", action="store_true", help="Delete dead casks automatically")
    parser.add_argument("--max-workers", type=int, default=20, help="Concurrent checks (default: 20)")
    args = parser.parse_args()

    print("==> Extracting cask URLs via Homebrew...")
    urls = get_all_cask_urls()
    print(f"Checking {len(urls)} casks...")

    dead = []
    alive = 0

    with ThreadPoolExecutor(max_workers=args.max_workers) as executor:
        futures = {executor.submit(check_url, token, url): token for token, url in urls.items()}
        for f in as_completed(futures):
            token, url, code, err = f.result()
            # 200 OK, 206 Partial Content, 301/302/304 redirects
            if code in ("200", "206", "301", "302", "304"):
                alive += 1
            else:
                # Retry once with full brew fetch to rule out curl quirks
                retry_res = subprocess.run(
                    ["brew", "fetch", "--cask", f"thedavidweng/unsigned-tap/{token}"],
                    capture_output=True,
                    text=True
                )
                if retry_res.returncode == 0:
                    alive += 1
                else:
                    error_msg = retry_res.stderr.strip().splitlines()[-1] if retry_res.stderr else f"HTTP {code}"
                    dead.append((token, url, error_msg))
                    print(f"❌ DEAD CASK: {token} -> {error_msg}")

    print("\n" + "=" * 50)
    print("Health Check Summary:")
    print(f"  Total casks: {len(urls)}")
    print(f"  Installable / Alive: {alive}")
    print(f"  Dead / Broken: {len(dead)}")
    print("=" * 50)

    if dead:
        print("\nDead casks:")
        for token, url, err in dead:
            print(f"  - {token}: {url} ({err})")

        if args.delete:
            print("\n==> Deleting dead casks...")
            for token, _, _ in dead:
                file_path = CASKS_DIR / f"{token}.rb"
                if file_path.exists():
                    file_path.unlink()
                    print(f"  Deleted {file_path.name}")
        sys.exit(1)
    else:
        print("\n✅ All casks can be successfully downloaded and installed!")
        sys.exit(0)

if __name__ == "__main__":
    main()
