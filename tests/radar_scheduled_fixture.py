import json
import os
import subprocess
import sys
import time
from pathlib import Path

repo = "thedavidweng/homebrew-unsigned-tap"
if os.environ["GITHUB_REPOSITORY"] != repo:
    raise SystemExit("Unexpected repository")
if os.environ["GITHUB_REF"] != "refs/heads/test/radar-scheduled-e2e":
    raise SystemExit("Unexpected branch")


def gh(*args):
    return subprocess.check_output(["gh", *args], text=True).strip()


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import radar

health = json.loads(Path(os.environ["DEAD_JSON"]).read_text())
snapshot = json.loads(Path(os.environ["SNAPSHOT_JSON"]).read_text())
if not health.get("total") or snapshot.get("treesheets") != ["3333"]:
    raise SystemExit("Expected real health and snapshot evidence")

number = os.environ["FIXTURE_ISSUE_NUMBER"]
if not number.isdecimal():
    raise SystemExit("Invalid fixture issue number")
details = json.loads(gh("api", f"repos/{repo}/issues/{number}"))
title = details["title"]
url = details["html_url"]
if (not title.startswith("test radarfixture") or details["user"]["login"] != repo.split("/", 1)[0]
        or details["state"] != "open" or "pull_request" in details):
    raise SystemExit("Test issue identity check failed")
print("Test issue:", url, flush=True)
original_gh = radar.gh
original_edit = radar.gh_create_with_body


def guarded_gh(*args, repo=None):
    if args[:2] == ("issue", "close"):
        raise RuntimeError("Radar must not close an issue in this fixture")
    result = original_gh(*args, repo=repo)
    if args[:2] == ("issue", "list") and json.loads(result) != [{"number": int(number)}]:
        raise RuntimeError("Issue search did not resolve exclusively to the fixture")
    return result


def guarded_edit(args, target_repo, body):
    if args != ["issue", "edit", number] or target_repo != repo:
        raise RuntimeError("Refusing to modify a non-fixture issue")
    return original_edit(args, target_repo,
                         "TEST FIXTURE: isolated workflow with live health evidence.\n\n" + body)


try:
    for _ in range(40):
        found = json.loads(original_gh("issue", "list", "--state", "open", "--search",
                                       f"{title} in:title", "--json", "number", repo=repo))
        if found == [{"number": int(number)}]:
            break
        time.sleep(3)
    else:
        raise RuntimeError("Test issue not uniquely searchable")

    radar.TITLE = title
    radar.gh = guarded_gh
    radar.gh_create_with_body = guarded_edit
    radar.main()
    body = json.loads(gh("api", f"repos/{repo}/issues/{number}"))["body"]
    if not body.startswith("TEST FIXTURE: isolated workflow with live health evidence."):
        raise RuntimeError("Fixture note missing")
    for label, key in (("HTTP 404/410 downloads (healthcheck)", "dead"),
                       ("Unverified downloads (healthcheck)", "unverified")):
        section = body.split(f"## {label}\n", 1)[1].split("\n## ", 1)[0]
        if any(f"`{item['token']}`" not in section for item in health[key]):
            raise RuntimeError(f"Missing {key} health result")
    if "`treesheets` — upstream 3333; livecheck arm: 2.23.1 → 2.23.1 (current)" not in body:
        raise RuntimeError("Expected live TreeSheets conflict missing")
    print(f"Verified issue update using {health['total']} live download checks", flush=True)
finally:
    gh("issue", "close", number, "--repo", repo)
    if gh("api", f"repos/{repo}/issues/{number}", "--jq", ".state") != "closed":
        raise RuntimeError("Test issue did not close")
    print("Closed test issue:", url, flush=True)
