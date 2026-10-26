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


def bump_cask_pr(*args):
    """Run brew bump-cask-pr, tolerating a pre-release-only livecheck result.

    `livecheck` with :github_latest can still surface a tag that audit rejects
    as a GitHub pre-release. That is not a reason to fail every other cask in
    the run, so it is reported and skipped.
    """
    proc = subprocess.run(("brew", "bump-cask-pr", *args), text=True, capture_output=True)
    output = (proc.stdout or "") + (proc.stderr or "")
    if proc.returncode != 0:
        if "is a GitHub pre-release" in output:
            print(f"::warning::skipping pre-release bump: {' '.join(args)}", file=sys.stderr)
            return False
        print(output.strip() or f"brew bump-cask-pr exited {proc.returncode}", file=sys.stderr)
        raise subprocess.CalledProcessError(proc.returncode, proc.args, proc.stdout, proc.stderr)
    if proc.stdout:
        print(proc.stdout, end="")
    return True


def livecheck_errors(data):
    """Return per-cask livecheck errors without aborting the whole run.

    One upstream 503 used to fail every scheduled bump, including unrelated
    casks. Errors are reported to the caller and the affected cask is skipped;
    a cask is only bumped when every architecture resolved cleanly.
    """
    return [result for results in data.values() for result in results
            if result.get("status") == "error"]


def plan(data):
    errors = livecheck_errors(data)
    failed_casks = {result.get("cask") for result in errors}
    versions = {}
    for arch, results in data.items():
        for result in results:
            if result.get("status") == "error" or result.get("cask") in failed_casks:
                continue
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


def channel_coverage(pr, cask, tap, default_branch):
    branch = pr["head"]["ref"]
    run("git", "-C", tap, "fetch", "origin", branch, default_branch)
    base = output("git", "-C", tap, "merge-base", "origin/" + branch, "origin/" + default_branch).strip()
    sources = [output("git", "-C", tap, "show", ref + ":Casks/" + cask + ".rb")
               for ref in (base, "origin/" + branch)]
    return set(json.loads(output("brew", "ruby", "-e", '''
require "cask/cask_loader"; require "simulate_system"; require "macos_version"
puts JSON.generate([:arm, :intel].select do |arch|
  MacOSVersion::SYMBOLS.any? do |os, version|
    next false if MacOSVersion.new(version) < MacOS.version

    Homebrew::SimulateSystem.with(os: os, arch: arch) do
      values = ARGV.map do |source|
        c = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
        [c.version.to_s, c.sha256.to_s, c.url.to_s, c.livecheck.skip?]
      end
      values[0] != values[1]
    end
  end
end)
''', "--", *sources)))


def bot_authors(repo):
    """Logins whose bump branches may be refreshed in place.

    Bumps used to be pushed with GITHUB_TOKEN (github-actions[bot]); since the
    PAT switch they are pushed authenticated as the repository owner.
    """
    return {"github-actions[bot]", repo.split("/", 1)[0]}


def pending_prs(cask, prs, repo, tap, default_branch, architectures):
    pending = []
    covered = set()
    for pr in prs:
        if (pr["user"]["login"] not in bot_authors(repo)
                or pr["head"]["repo"]["full_name"] != repo
                or not pr["head"]["ref"].startswith("bump-" + cask + "-")):
            continue
        pages = json.loads(output("gh", "api", f"repos/{repo}/pulls/{pr['number']}/files", "--paginate", "--slurp"))
        files = [file for page in pages for file in page]
        if len(files) != 1 or files[0]["filename"] != f"Casks/{cask}.rb" or files[0]["status"] != "modified":
            continue
        scope = channel_coverage(pr, cask, tap, default_branch) & architectures
        if scope & covered:
            raise ValueError(f"Overlapping pending updates for {cask}; review channel coverage before cleanup")
        if scope:
            pending.append((pr, scope))
            covered |= scope
    return pending, architectures - covered


def bump(cask, args, prs, repo, default_branch, source="livecheck"):
    qualified = "thedavidweng/unsigned-tap/" + cask
    tap = output("brew", "--repository", "thedavidweng/unsigned-tap").strip()
    versions = ({arch: args[0].split("=", 1)[1] for arch in ("arm", "intel")}
                if args[0].startswith("--version=") else
                {arg.split("=", 1)[0].removeprefix("--version-"): arg.split("=", 1)[1] for arg in args})
    architectures = set(versions)
    pending, uncovered = pending_prs(cask, prs, repo, tap, default_branch, architectures)
    os.chdir(tap)
    for pr, scope in pending:
        branch = pr["head"]["ref"]
        run("git", "checkout", "-B", branch, "origin/" + branch)
        before = output("git", "rev-parse", "HEAD").strip()
        run("git", "merge", "--no-edit", "origin/" + default_branch)
        # Recheck each pending channel: preserve legacy definitions and never downgrade.
        data = {}
        for arch in ("arm", "intel"):
            if arch not in scope:
                continue
            data[arch] = json.loads(output(
                "brew", "ruby", "-e",
                'require "dev-cmd/livecheck"; require "simulate_system"; Homebrew::SimulateSystem.with(arch: ARGV.shift.to_sym) { Homebrew::DevCmd::LivecheckCmd.new(ARGV).run }',
                "--", arch, qualified, "--newer-only", "--extract-plist", "--json"))
        # A bump must never be produced from an incomplete livecheck result.
        errors = livecheck_errors(data)
        if errors:
            raise ValueError(json.dumps(errors))
        rows = plan(data)
        skipped = False
        if rows:
            token, version, new_args = rows[0]
            assert len(rows) == 1 and token == cask
            skipped = not bump_cask_pr("--write-only", "--commit", *new_args, qualified)
        if skipped:
            print(f"Skipped pre-release refresh for PR #{pr['number']} ({cask})")
            run("git", "checkout", default_branch)
            continue
        after = output("git", "rev-parse", "HEAD").strip()
        if after != before:
            run("git", "push", "origin", "HEAD:" + branch)
            if rows:
                run("gh", "pr", "edit", str(pr["number"]), "--repo", repo, "--title", cask + " " + version)
            # The push triggers pull_request CI on the refreshed head (PAT
            # identity); no explicit verification dispatch is needed.
        print(f"Checked existing PR #{pr['number']} for {cask}: {sorted(scope)}")
        run("git", "checkout", default_branch)
    if uncovered:
        run("git", "fetch", "origin", default_branch)
        run("git", "checkout", default_branch)
        run("git", "merge", "--ff-only", "origin/" + default_branch)
        data = {}
        for arch in ("arm", "intel"):
            if arch not in uncovered:
                continue
            data[arch] = json.loads(output(
                "brew", "ruby", "-e",
                'require "dev-cmd/livecheck"; require "simulate_system"; Homebrew::SimulateSystem.with(arch: ARGV.shift.to_sym) { Homebrew::DevCmd::LivecheckCmd.new(ARGV).run }',
                "--", arch, qualified, "--newer-only", "--extract-plist", "--json"))
        # A bump must never be produced from an incomplete livecheck result.
        errors = livecheck_errors(data)
        if errors:
            raise ValueError(json.dumps(errors))
        rows = plan(data)
        if rows:
            token, _version, new_args = rows[0]
            assert len(rows) == 1 and token == cask
            uncovered = {arch for arch, results in data.items() if plan({arch: results})}
        elif (source == "catchup" and args
                and all(a.startswith("--version") for a in args)):
            # Livecheck is blind to this cask but upstream is newer (the
            # catch-up row carries an explicit version). Attempt it directly:
            # the download and audit inside bump-cask-pr still validate it,
            # and a bogus version fails here without opening anything.
            new_args = list(args)
        else:
            print(f"No remaining update for {cask} on latest {default_branch}")
            return
        if not bump_cask_pr("--no-fork", *new_args, qualified):
            return
        pages = json.loads(output("gh", "api", f"repos/{repo}/pulls", "--method", "GET",
                                  "-f", "state=open", "-f", "base=" + default_branch, "--paginate", "--slurp"))
        created, remaining = pending_prs(cask, [pr for page in pages for pr in page], repo, tap, default_branch, uncovered)
        if remaining:
            raise ValueError(f"No created update PR covers {cask}: {sorted(remaining)}")
        # PR creation triggers pull_request CI on the new branch (PAT
        # identity); no explicit verification dispatch is needed.


if __name__ == "__main__":
    if sys.argv[1] == "plan":
        data = {arch: json.loads(Path(f"outdated-casks-{arch}.json").read_text()) for arch in ("arm", "intel")}
        Path("outdated-casks.json").write_text(json.dumps(data, indent=2))
        errors = livecheck_errors(data)
        for error in errors:
            messages = "; ".join(error.get("messages") or [])
            print(f"::warning::livecheck failed for {error.get('cask')}: {messages}", file=sys.stderr)
        resolved = [result for results in data.values() for result in results
                    if result.get("status") != "error"]
        if errors and not resolved:
            # Do not fail here: per-cask errors are already warnings, and the
            # upstream catch-up step may still produce rows. An empty result
            # exits cleanly downstream ("No outdated casks found").
            print("::warning::all livecheck results failed; nothing to plan from livecheck",
                  file=sys.stderr)
        for cask, version, args in plan(data):
            print(cask + "\t" + version + "\t" + " ".join(args))
    elif sys.argv[1] == "bump":
        bump(sys.argv[2], sys.argv[4:], json.loads(Path("open-cask-prs.json").read_text()),
             os.environ["GITHUB_REPOSITORY"], os.environ["DEFAULT_BRANCH"],
             source=sys.argv[3])
    else:
        raise ValueError("Expected plan or bump")
