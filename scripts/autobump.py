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


def verify_head(repo, branch, cask):
    run("gh", "workflow", "run", "ci.yml", "--repo", repo, "--ref", branch,
        "-f", "casks=" + cask, "-f", "skip_install=true")
    run("gh", "workflow", "run", "workflow-lint.yml", "--repo", repo, "--ref", branch)


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


def pending_prs(cask, prs, repo, tap, default_branch, architectures):
    pending = []
    covered = set()
    for pr in prs:
        if (pr["user"]["login"] != "github-actions[bot]"
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


def bump(cask, args, prs, repo, default_branch):
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
        rows = plan(data)
        if rows:
            token, version, new_args = rows[0]
            assert len(rows) == 1 and token == cask
            run("brew", "bump-cask-pr", "--write-only", "--commit", *new_args, qualified)
        after = output("git", "rev-parse", "HEAD").strip()
        if after != before:
            run("git", "push", "origin", "HEAD:" + branch)
            if rows:
                run("gh", "pr", "edit", str(pr["number"]), "--repo", repo, "--title", cask + " " + version)
            # GITHUB_TOKEN pushes need explicit workflows to verify the refreshed head.
            verify_head(repo, branch, cask)
        print(f"Checked existing PR #{pr['number']} for {cask}: {sorted(scope)}")
        run("git", "checkout", default_branch)
    if uncovered:
        new_args = args if uncovered == architectures else ["--version-" + arch + "=" + versions[arch] for arch in sorted(uncovered)]
        run("brew", "bump-cask-pr", "--no-fork", *new_args, qualified)
        pages = json.loads(output("gh", "api", f"repos/{repo}/pulls", "--method", "GET",
                                  "-f", "state=open", "-f", "base=" + default_branch, "--paginate", "--slurp"))
        created, remaining = pending_prs(cask, [pr for page in pages for pr in page], repo, tap, default_branch, uncovered)
        if remaining:
            raise ValueError(f"No created update PR covers {cask}: {sorted(remaining)}")
        for pr, scope in created:
            verify_head(repo, pr["head"]["ref"], cask)


if __name__ == "__main__":
    if sys.argv[1] == "plan":
        data = {arch: json.loads(Path(f"outdated-casks-{arch}.json").read_text()) for arch in ("arm", "intel")}
        Path("outdated-casks.json").write_text(json.dumps(data, indent=2))
        for cask, version, args in plan(data):
            print(cask + "\t" + version + "\t" + " ".join(args))
    elif sys.argv[1] == "bump":
        bump(sys.argv[2], sys.argv[3:], json.loads(Path("open-cask-prs.json").read_text()),
             os.environ["GITHUB_REPOSITORY"], os.environ["DEFAULT_BRANCH"])
    else:
        raise ValueError("Expected plan or bump")
