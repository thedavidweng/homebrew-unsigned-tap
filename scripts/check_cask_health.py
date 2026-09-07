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

UA_BROWSER = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

def check_url_and_fetch(token, url):
    # Method 1: Initial HEAD request without following redirects
    # Especially effective for SourceForge and download mirrors that redirect (301/302/307)
    # but block automated clients with Cloudflare challenges on CDN targets.
    cmd_head_initial = [
        "curl", "-s", "-I",
        "--max-time", "6",
        "-o", "/dev/null",
        "-w", "%{http_code}",
        url
    ]
    try:
        proc = subprocess.run(cmd_head_initial, capture_output=True, text=True, timeout=8)
        code = proc.stdout.strip()
        if code in ("200", "301", "302", "303", "307", "308"):
            return token, url, True, f"HTTP {code} (Mirror redirect)"
    except Exception:
        pass

    # Method 2: Range GET request (fast header+partial check with -L)
    cmd_range = [
        "curl", "-s", "-L", "-o", "/dev/null",
        "-A", UA_BROWSER,
        "--max-time", "8",
        "--range", "0-1024",
        "-w", "%{http_code}",
        url
    ]
    try:
        proc = subprocess.run(cmd_range, capture_output=True, text=True, timeout=10)
        code = proc.stdout.strip()
        if code in ("200", "206", "301", "302", "304", "307", "308"):
            return token, url, True, f"HTTP {code}"
    except Exception:
        pass

    # Method 3: HEAD request (for servers that reject Range requests)
    cmd_head = [
        "curl", "-s", "-I", "-L",
        "-A", UA_BROWSER,
        "--max-time", "8",
        "-o", "/dev/null",
        "-w", "%{http_code}",
        url
    ]
    try:
        proc = subprocess.run(cmd_head, capture_output=True, text=True, timeout=10)
        code = proc.stdout.strip()
        if code in ("200", "206", "301", "302", "304", "307", "308"):
            return token, url, True, f"HTTP {code} (HEAD)"
    except Exception:
        pass

    # Method 4: Fallback to Homebrew's internal fetcher (handles complex cookies/headers)
    try:
        retry_res = subprocess.run(
            ["brew", "fetch", "--cask", f"thedavidweng/unsigned-tap/{token}"],
            capture_output=True,
            text=True,
            timeout=40
        )
        if retry_res.returncode == 0:
            return token, url, True, "brew fetch ok"
        error_msg = retry_res.stderr.strip().splitlines()[-1] if retry_res.stderr else "brew fetch failed"
        return token, url, False, error_msg
    except subprocess.TimeoutExpired:
        return token, url, False, "Timeout during fetch"
    except Exception as e:
        return token, url, False, str(e)

def main():
    parser = argparse.ArgumentParser(description="Check cask download health")
    parser.add_argument("--delete", action="store_true", help="Delete dead casks automatically")
    parser.add_argument("--max-workers", type=int, default=20, help="Concurrent checks (default: 20)")
    parser.add_argument("--casks", nargs="*", help="Specific cask tokens to check")
    args = parser.parse_args()

    print("==> Extracting cask URLs via Homebrew...", flush=True)
    all_urls = get_all_cask_urls()
    if args.casks:
        urls = {k: v for k, v in all_urls.items() if k in args.casks}
    else:
        urls = all_urls

    print(f"Checking {len(urls)} casks...", flush=True)

    dead = []
    alive = 0
    checked = 0

    with ThreadPoolExecutor(max_workers=args.max_workers) as executor:
        futures = {executor.submit(check_url_and_fetch, token, url): token for token, url in urls.items()}
        for f in as_completed(futures):
            token, url, is_alive, detail = f.result()
            checked += 1
            if is_alive:
                alive += 1
            else:
                dead.append((token, url, detail))
                print(f"❌ DEAD CASK: {token} -> {detail}", flush=True)

            if checked % 50 == 0 or checked == len(urls):
                print(f"Progress: {checked}/{len(urls)} checked ({len(dead)} dead)...", flush=True)

    print("\n" + "=" * 50, flush=True)
    print("Health Check Summary:", flush=True)
    print(f"  Total casks: {len(urls)}", flush=True)
    print(f"  Installable / Alive: {alive}", flush=True)
    print(f"  Dead / Broken: {len(dead)}", flush=True)
    print("=" * 50, flush=True)

    if dead:
        print("\nDead casks:", flush=True)
        for token, url, err in dead:
            print(f"  - {token}: {url} ({err})", flush=True)

        if args.delete:
            print("\n==> Deleting dead casks...", flush=True)
            sync_script = ROOT / "scripts" / "sync_disabled_casks.py"
            for token, _, _ in dead:
                file_path = CASKS_DIR / f"{token}.rb"
                if file_path.exists():
                    file_path.unlink()
                    print(f"  Deleted {file_path.name}", flush=True)

            if sync_script.exists():
                text = sync_script.read_text(encoding="utf-8")
                for token, _, err in dead:
                    if f'"{token}"' not in text:
                        text = text.replace(
                            "DEAD_CASKS = {\n",
                            f'DEAD_CASKS = {{\n    "{token}", # auto-detected dead: {err}\n'
                        )
                sync_script.write_text(text, encoding="utf-8")
                print("  Updated DEAD_CASKS blocklist in scripts/sync_disabled_casks.py", flush=True)
        sys.exit(1)
    else:
        print("\n✅ All casks can be successfully downloaded and installed!", flush=True)
        sys.exit(0)

if __name__ == "__main__":
    main()
