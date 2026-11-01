"""Weekly maintenance radar: one tracking issue for everything needing eyes.

Aggregates read-only signals (never edits casks):
- dead downloads, from `check_cask_health.py --json-out`
- tap casks removed upstream (excluding intentional DEAD_CASKS retirements)
- upstream-newer single-version casks with no open PR (the catch-up path
  attempts them every autobump run; still listed next week means the bump
  keeps failing and a human should look)
- open bump PRs still waiting (normally merged by automation; lingering
  means red checks)
- livecheck errors and failed bumps from the latest scheduled autobump evidence

Upserts a single open issue; closes it with an all-clear note when clean.
"""
import importlib.util
import json
import os
import subprocess
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
TITLE = "Maintenance radar (automated)"

TAP_CASK_DIR = Path(os.environ.get("TAP_CASK_DIR", str(ROOT / "Casks")))
SNAPSHOT_JSON = os.environ.get("SNAPSHOT_JSON", "")
DEAD_JSON = os.environ.get("DEAD_JSON", "")


def load_upstream():
    """{token: [version literals]} from the daily-sync snapshot, or {}."""
    if SNAPSHOT_JSON and Path(SNAPSHOT_JSON).exists():
        import upstream_catchup
        return upstream_catchup.load_snapshot(SNAPSHOT_JSON)
    return {}


def gh(*args, repo=None):
    # gh api takes the repo inside the path and rejects --repo; every other
    # subcommand used here needs it.
    cmd = ["gh", *args]
    if repo is not None:
        cmd += ["--repo", repo]
    return subprocess.check_output(cmd, text=True)


def retired_tokens():
    spec = importlib.util.spec_from_file_location(
        "sync_disabled_casks", ROOT / "scripts/sync_disabled_casks.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return set(module.DEAD_CASKS)


def missing_upstream(tap_dir, upstream_tokens, retired):
    return sorted(p.stem for p in Path(tap_dir).glob("*.rb")
                  if p.stem not in upstream_tokens and p.stem not in retired)


def catchup_and_inflight(repo):
    import upstream_catchup
    pairs = upstream_catchup.candidates(TAP_CASK_DIR, load_upstream(), set(), set(), set())
    rows = upstream_catchup.upstream_newer(pairs)
    prs = json.loads(gh("pr", "list", "--state", "open", "--limit", "100",
                        "--json", "number,title,headRefName", repo=repo))
    inflight = sorted((p["number"], p["title"]) for p in prs
                      if p["headRefName"].startswith(("bump-", "sync/")))
    return rows, inflight


def autobump_evidence(repo):
    """Livecheck errors and failed bumps from the latest scheduled run.

    Uses only long-stable gh api calls: the preinstalled runner gh predates
    several gh run list/download flags.
    """
    try:
        # Query strings stay inline: gh api with -f switches to POST.
        runs = json.loads(gh("api", f"repos/{repo}/actions/workflows/autobump.yml/runs"
                                    "?event=schedule&status=completed&per_page=1"))
        scheduled = runs.get("workflow_runs", [])
        if not scheduled:
            return {"<evidence unavailable>": "no completed scheduled autobump"}, []
        if scheduled[0].get("conclusion") != "success":
            return {"<evidence unavailable>": "latest scheduled autobump did not succeed"}, []
        run_id = scheduled[0]["id"]
        arts = json.loads(gh("api", f"repos/{repo}/actions/runs/{run_id}/artifacts"
                                    "?name=livecheck-casks&per_page=10"))
        aids = [art["id"] for art in arts.get("artifacts", [])
                if not art.get("expired")
                and art.get("workflow_run", {}).get("id") == run_id]
        if not aids:
            return {"<evidence unavailable>": "latest scheduled autobump evidence missing"}, []
        proc = subprocess.run(["gh", "api",
                               f"repos/{repo}/actions/artifacts/{aids[0]}/zip"],
                              check=True, capture_output=True)
        import io
        import zipfile
        with zipfile.ZipFile(io.BytesIO(proc.stdout)) as archive:
            data = json.loads(archive.read("outdated-casks.json").decode())
            failures = sorted(set(archive.read("bump-failures.txt").decode().splitlines()))
    except Exception as exc:
        return {"<evidence unavailable>": str(exc)}, []
    errors = {}
    for results in data.values():
        for result in results:
            if result.get("status") == "error":
                errors.setdefault(result.get("cask", "?"), set()).update(result.get("messages") or [])
    return {cask: sorted(msgs) for cask, msgs in sorted(errors.items())}, failures


def section(title, lines):
    body = f"## {title}\n"
    if not lines:
        return body + "None.\n"
    return body + "".join(f"- {line}\n" for line in lines)


def build_body(today, dead, missing, catchups, inflight, errors, failures):
    parts = [
        f"Automated weekly summary for human review. "
        f"Everything else in this tap updates and merges itself; "
        f"only the items below need eyes. ({today})",
        "",
        section("Dead downloads (healthcheck)",
                [f"`{d['token']}` — {d['detail']}" for d in dead]),
        section("Removed upstream, still in this tap",
                [f"`{token}`" for token in missing]),
        section("Upstream newer, catch-up pending (bump attempted each run; "
                "still here next week = bump keeps failing)",
                [f"`{token}` → {version}" for token, version in catchups]),
        section("Open bump/sync PRs (automation merges when green)",
                [f"#{number} {title}" for number, title in inflight]),
        section("Livecheck errors in latest autobump evidence",
                [f"`{cask}` — {'; '.join(msgs)}" for cask, msgs in errors.items()
                 if cask != "<evidence unavailable>"] +
                (["evidence unavailable"] if "<evidence unavailable>" in errors else [])),
        section("Failed bumps in latest scheduled autobump",
                [f"`{cask}`" for cask in failures] +
                (["evidence unavailable"] if "<evidence unavailable>" in errors else [])),
    ]
    return "\n".join(parts) + "\n"


def upsert_issue(repo, body, clean):
    found = json.loads(gh("issue", "list", "--state", "open",
                          "--search", f"{TITLE} in:title",
                          "--json", "number", repo=repo))
    if clean:
        for issue in found:
            gh("issue", "close", str(issue["number"]),
               "--comment", "All clear: no dead downloads, no removed casks, "
                            "nothing stuck upstream, livecheck clean.", repo=repo)
        print("radar clean; closed any open radar issue")
        return
    if found:
        number = found[0]["number"]
        gh_create_with_body(["issue", "edit", str(number)], repo, body)
        print(f"updated radar issue #{number}")
    else:
        out = gh_create_with_body(["issue", "create", "--title", TITLE], repo, body)
        print(f"created radar issue: {out.strip()}")


def gh_create_with_body(args, repo, body):
    # Small indirection so tests can stub issue creation.
    proc = subprocess.run(["gh", *args, "--repo", repo, "--body-file", "-"],
                          input=body, text=True, capture_output=True)
    proc.check_returncode()
    return proc.stdout


def main():
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    if not repo:
        raise SystemExit("GITHUB_REPOSITORY is required")
    dead = []
    if DEAD_JSON and Path(DEAD_JSON).exists():
        dead = json.loads(Path(DEAD_JSON).read_text()).get("dead", [])
    upstream = load_upstream()
    missing = missing_upstream(TAP_CASK_DIR, set(upstream), retired_tokens()) if upstream else []
    rows, inflight = catchup_and_inflight(repo)
    errors, failures = autobump_evidence(repo)
    clean = not dead and not missing and not rows and not errors and not failures
    body = build_body(date.today().isoformat(), dead, missing, rows, inflight, errors, failures)
    upsert_issue(repo, body, clean)


if __name__ == "__main__":
    main()
