"""Plan architecture-aware bumps and refresh an existing bot PR in place."""
import json
import os
from pathlib import Path
import subprocess
import sys


def output(*args):
    return subprocess.check_output(args, text=True)


def run(*args):
    subprocess.run(args, check=True)


def plan(data):
    versions = {}
    for arch, results in data.items():
        for result in results:
            if result.get("status") == "error":
                raise ValueError(json.dumps(result))
            if "version" in result and result["version"]["outdated"]:
                versions.setdefault(result["cask"], {})[arch] = result["version"]["latest"]
    rows = []
    for cask, latest in sorted(versions.items()):
        if len(latest) == 2 and latest["arm"] == latest["intel"]:
            args = ["--version=" + latest["arm"]]
            version = latest["arm"]
        else:
            args = ["--version-" + arch + "=" + version for arch, version in latest.items()]
            version = latest["arm"] if "arm" in latest else latest["intel"]
            if len(latest) == 1:
                version += "-" + next(iter(latest)) + "-only"
        rows.append((cask, version, args))
    return rows


def pending_pr(cask, prs, repo):
    pending = []
    for pr in prs:
        if (pr["user"]["login"] != "github-actions[bot]"
                or pr["head"]["repo"]["full_name"] != repo
                or not pr["head"]["ref"].startswith("bump-" + cask + "-")):
            continue
        pages = json.loads(output("gh", "api", f"repos/{repo}/pulls/{pr['number']}/files", "--paginate", "--slurp"))
        files = [file for page in pages for file in page]
        if len(files) == 1 and files[0]["filename"] == f"Casks/{cask}.rb" and files[0]["status"] == "modified":
            pending.append(pr)
    if len(pending) > 1:
        raise ValueError(f"Multiple pending updates for {cask}: {[p['number'] for p in pending]}; review channel coverage before cleanup")
    return pending[0] if pending else None


def bump(cask, version, args, prs, repo, default_branch):
    pr = pending_pr(cask, prs, repo)
    qualified = "thedavidweng/unsigned-tap/" + cask
    if pr is None:
        run("brew", "bump-cask-pr", "--no-fork", *args, qualified)
        return
    tap = output("brew", "--repository", "thedavidweng/unsigned-tap").strip()
    os.chdir(tap)
    branch = pr["head"]["ref"]
    run("git", "fetch", "origin", default_branch, branch)
    run("git", "checkout", "-B", branch, "origin/" + branch)
    run("git", "merge", "--no-edit", "origin/" + default_branch)
    # Recheck the pending definition: preserve its platform branches and never downgrade it.
    data = {}
    for arch in ("arm", "intel"):
        data[arch] = json.loads(output(
            "brew", "ruby", "-e",
            'require "dev-cmd/livecheck"; require "simulate_system"; Homebrew::SimulateSystem.with(arch: ARGV.shift.to_sym) { Homebrew::DevCmd::LivecheckCmd.new(ARGV).run }',
            "--", arch, qualified, "--newer-only", "--extract-plist", "--json"))
    rows = plan(data)
    if rows:
        token, version, args = rows[0]
        assert len(rows) == 1 and token == cask
        run("brew", "bump-cask-pr", "--write-only", "--commit", *args, qualified)
    run("git", "push", "origin", "HEAD:" + branch)
    if rows:
        run("gh", "pr", "edit", str(pr["number"]), "--repo", repo, "--title", cask + " " + version)
    print(f"Refreshed existing PR #{pr['number']} for {cask}")
    run("git", "checkout", default_branch)


if __name__ == "__main__":
    if sys.argv[1] == "plan":
        data = {arch: json.loads(Path(f"outdated-casks-{arch}.json").read_text()) for arch in ("arm", "intel")}
        Path("outdated-casks.json").write_text(json.dumps(data, indent=2))
        for cask, version, args in plan(data):
            print(cask + "\t" + version + "\t" + " ".join(args))
    elif sys.argv[1] == "bump":
        bump(sys.argv[2], sys.argv[3], sys.argv[4:], json.loads(Path("open-cask-prs.json").read_text()),
             os.environ["GITHUB_REPOSITORY"], os.environ["DEFAULT_BRANCH"])
    else:
        raise ValueError("Expected plan or bump")
