#!/usr/bin/env python3
"""
check_cask_health.py: Check download URL reachability for all casks in the tap.

Usage:
  python3 scripts/check_cask_health.py             # exit 1 if dead or unverified
  python3 scripts/check_cask_health.py --delete    # remove casks confirmed missing by Homebrew
"""

import argparse
import json
import os
import re
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
    """Return True for reachable URLs, False for confirmed missing URLs, else None."""
    results = []
    for method in (["-I"], ["--range", "0-1024", "--max-filesize", "1025", "-A", UA_BROWSER]):
        cmd = ["curl", "-sS", "-L", *method,
               "--max-time", "8", "-o", "/dev/null", "-w", "%{http_code} %{size_download}", url]
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        except subprocess.TimeoutExpired:
            results.append("timeout")
            continue
        code, _, downloaded = proc.stdout.strip().partition(" ")
        limited = (proc.returncode in (56, 63) and downloaded.isdigit() and int(downloaded) >= 1025
                   and "maximum allowed file size" in proc.stderr.lower())
        if code in ("200", "206") and (proc.returncode == 0 or limited):
            return token, url, True, f"HTTP {code}"
        if proc.returncode == 0:
            results.append(code)
        else:
            detail = proc.stderr.strip() or "curl failed"
            results.append(f"HTTP {code}: {detail}" if code and code != "000" else detail)

    if all(code in ("404", "410") for code in results):
        return token, url, False, f"HTTP {results[0]} (HEAD), {results[1]} (GET)"
    return token, url, None, f"HEAD: {results[0]}; GET: {results[1]}"


def homebrew_confirms_missing(token, file_path):
    tap = Path(subprocess.check_output(
        ["brew", "--repository", "thedavidweng/unsigned-tap"], text=True,
    ).strip())
    installed_cask = tap / "Casks" / f"{token}.rb"
    if not installed_cask.is_file() or installed_cask.read_bytes() != file_path.read_bytes():
        return False
    try:
        result = subprocess.run(
            ["brew", "fetch", "--cask", f"thedavidweng/unsigned-tap/{token}"],
            capture_output=True, text=True, timeout=40,
        )
    except subprocess.TimeoutExpired:
        return False
    return result.returncode != 0 and bool(re.search(
        r"(?:returned error: |HTTP(?:/\d(?:\.\d)?)? (?:error )?)(?:404|410)\b",
        result.stderr, re.IGNORECASE,
    ))


def main():
    parser = argparse.ArgumentParser(description="Check cask download health")
    parser.add_argument("--delete", action="store_true", help="Delete dead casks automatically")
    parser.add_argument("--max-workers", type=int, default=20, help="Concurrent checks (default: 20)")
    parser.add_argument("--casks", nargs="*", help="Specific cask tokens to check")
    parser.add_argument("--json-out", help="Write machine-readable result JSON for the radar issue")
    args = parser.parse_args()

    print("==> Extracting cask URLs via Homebrew...", flush=True)
    all_urls = get_all_cask_urls()
    if args.casks:
        urls = {k: v for k, v in all_urls.items() if k in args.casks}
    else:
        urls = all_urls

    if not urls:
        raise SystemExit("No cask URLs to check")

    print(f"Checking {len(urls)} casks...", flush=True)

    dead = []
    unverified = []
    alive = 0
    checked = 0

    with ThreadPoolExecutor(max_workers=args.max_workers) as executor:
        futures = {executor.submit(check_url_and_fetch, token, url): token for token, url in urls.items()}
        for f in as_completed(futures):
            token, url, is_alive, detail = f.result()
            checked += 1
            if is_alive is True:
                alive += 1
            elif is_alive is False:
                dead.append((token, url, detail))
                print(f"HTTP 404/410: {token} -> {detail}", flush=True)
            else:
                unverified.append((token, url, detail))
                print(f"UNVERIFIED CASK: {token} -> {detail}", flush=True)

            if checked % 50 == 0 or checked == len(urls):
                print(f"Progress: {checked}/{len(urls)} checked ({len(dead)} dead, "
                      f"{len(unverified)} unverified)...", flush=True)

    if args.json_out:
        with open(args.json_out, "w", encoding="utf-8") as fh:
            json.dump({"total": len(urls), "alive": alive,
                       "dead": [{"token": t, "url": u, "detail": d} for t, u, d in dead],
                       "unverified": [{"token": t, "url": u, "detail": d} for t, u, d in unverified]},
                      fh, indent=2)

    print("\n" + "=" * 50, flush=True)
    print("Health Check Summary:", flush=True)
    print(f"  Total casks: {len(urls)}", flush=True)
    print(f"  Reachable: {alive}", flush=True)
    print(f"  HTTP 404/410: {len(dead)}", flush=True)
    print(f"  Unverified: {len(unverified)}", flush=True)
    print("=" * 50, flush=True)

    if dead:
        print("\nHTTP 404/410 casks:", flush=True)
        for token, url, err in dead:
            print(f"  - {token}: {url} ({err})", flush=True)

        if args.delete:
            print("\n==> Confirming missing casks with Homebrew...", flush=True)
            sync_script = ROOT / "scripts" / "sync_disabled_casks.py"
            deleted = []
            for token, _, _ in dead:
                file_path = CASKS_DIR / f"{token}.rb"
                if file_path.exists() and homebrew_confirms_missing(token, file_path):
                    file_path.unlink()
                    deleted.append(token)
                    print(f"  Deleted {file_path.name}", flush=True)
                else:
                    print(f"  Retained {file_path.name}: Homebrew did not confirm HTTP 404/410", flush=True)

            if deleted and sync_script.exists():
                text = sync_script.read_text(encoding="utf-8")
                for token, _, err in dead:
                    if token in deleted and f'"{token}"' not in text:
                        text = text.replace(
                            "DEAD_CASKS = {\n",
                            f'DEAD_CASKS = {{\n    "{token}", # auto-detected dead: {err}\n'
                        )
                sync_script.write_text(text, encoding="utf-8")
                print("  Updated DEAD_CASKS blocklist in scripts/sync_disabled_casks.py", flush=True)
    if unverified:
        print("\nUnverified casks:", flush=True)
        for token, url, err in unverified:
            print(f"  - {token}: {url} ({err})", flush=True)
    if dead or unverified:
        sys.exit(1)
    print("\nAll download URLs responded successfully.", flush=True)
    sys.exit(0)

if __name__ == "__main__":
    main()
