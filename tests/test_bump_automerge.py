"""Gate tests for the bump auto-merge workflow.

The script under test is the real `run:` block of
`.github/workflows/bump-automerge.yml`, extracted from the YAML and executed
against a stub `gh` on PATH. The stub models the real CLI, including the fact
that `--jq` takes exactly one argument and has no `-e` mode, so a regression to
`--jq -e` shows up here instead of only in production.

Most cases assert the PR is *not* merged: the script must fail closed when the
labels, the diff, or the check runs are missing, malformed, or bad.
"""

import json
import os
import pathlib
import stat
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/bump-automerge.yml"
REPO = "thedavidweng/homebrew-unsigned-tap"
OWNER = "thedavidweng"
SHA = "45c3f67c5571a0e89b2f31edaa4f346e0cb3f8e9"

STUB = r"""#!/usr/bin/env bash
set -u
DIR="${STUB_DIR:?}"
printf 'gh %s\n' "$*" >>"$DIR/calls.log"

# The real CLI's --jq accepts exactly one argument and has no -e mode.
prev=""
for a in "$@"; do
  if [[ "$prev" == "--jq" && "$a" == -* ]]; then
    echo "accepts 1 arg(s), received 2" >&2
    exit 1
  fi
  prev="$a"
done

if [[ "${1:-}" == "pr" && "${2:-}" == "list" ]]; then
  [[ -e "$DIR/fail.prlist" ]] && exit 1
  cat "$DIR/candidates.json"
  exit 0
fi

if [[ "${1:-}" == "pr" && "${2:-}" == "view" ]]; then
  mode=""; jqv=""
  shift 2
  shift  # PR number
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json) mode="$2"; shift 2 ;;
      --jq)   jqv="$2";  shift 2 ;;
      *)      shift ;;
    esac
  done
  if [[ "$mode" == "mergeable" ]]; then
    [[ -e "$DIR/fail.mergeable" ]] && exit 1
    cat "$DIR/mergeable"
    exit 0
  fi
  if [[ "$mode" == "labels" ]]; then
    [[ -e "$DIR/fail.labels" ]] && exit 1
    if [[ -e "$DIR/malformed.labels" ]]; then echo "oops"; exit 0; fi
    jq "$jqv" "$DIR/labels.object.json"
    exit 0
  fi
  exit 1
fi

if [[ "${1:-}" == "api" ]]; then
  url="${2:-}"; jqv=""
  shift 2
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --jq) jqv="$2"; shift 2 ;;
      *)    shift ;;
    esac
  done
  if [[ "$url" == *"/files" ]]; then
    [[ -e "$DIR/fail.files" ]] && exit 1
    cat "$DIR/files.json"
    exit 0
  fi
  if [[ "$url" == *"/check-runs"* ]]; then
    [[ -e "$DIR/fail.checks" ]] && exit 1
    jq "$jqv" "$DIR/checks.object.json"
    exit 0
  fi
  exit 1
fi

if [[ "${1:-}" == "pr" && "${2:-}" == "merge" ]]; then
  [[ -e "$DIR/fail.merge" ]] && exit 1
  printf 'MERGE %s\n' "$*" >>"$DIR/calls.log"
  exit 0
fi
exit 1
"""


def workflow_script():
    """Extract the automerge job's `run:` block from the workflow YAML."""
    lines = WORKFLOW.read_text().splitlines()
    start = lines.index("        run: |")
    body = []
    for line in lines[start + 1:]:
        if line.strip() and not line.startswith("          "):
            break
        body.append(line[10:] if line.startswith("          ") else "")
    return "\n".join(body) + "\n"


def check(name, conclusion="success", status="completed"):
    return {"name": name, "status": status, "conclusion": conclusion}


def healthy_checks():
    return [
        check("generate-matrix"),
        check("tap_syntax (macos-26)"),
        check("test sample (macos-26, arm)"),
        check("conclusion"),
        check("audit"),
        check("Workflow lint"),
        check("CodeQL (actions)"),
        check("CodeQL (python)"),
        check("CodeQL (ruby)"),
        check("triage"),
        check("Kilo Code Review"),
        # Advisory contexts the workflow deliberately tolerates.
        check("CodeRabbit", conclusion="neutral"),
        check("Enable auto-merge", conclusion="skipped"),
    ]


def candidate(number=305, branch="bump-zenmap-7.993", sha=SHA):
    return {
        "number": number,
        "headRefName": branch,
        "headRefOid": sha,
        "headRepository": {"nameWithOwner": REPO},
        "baseRefName": "main",
        "author": {"login": OWNER},
        "isDraft": False,
    }


class AutomergeGateTests(unittest.TestCase):
    def run_script(self, **scenario):
        """Run the real workflow script against the stub; return its output."""
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        d = pathlib.Path(tmp.name)

        (d / "candidates.json").write_text(
            json.dumps(scenario.get("candidates", [candidate()])))
        (d / "mergeable").write_text(scenario.get("mergeable", "MERGEABLE"))
        (d / "labels.object.json").write_text(json.dumps(
            {"labels": [{"name": n} for n in scenario.get("labels", [])]}))
        (d / "files.json").write_text(json.dumps(scenario.get("files", [
            {"status": "modified", "filename": "Casks/zenmap.rb"}])))
        (d / "checks.object.json").write_text(json.dumps(
            {"check_runs": scenario.get("checks", healthy_checks())}))
        for flag in scenario.get("fail", []):
            (d / flag).write_text("")
        for flag in scenario.get("malformed", []):
            (d / f"malformed.{flag}").write_text("")

        bindir = d / "bin"
        bindir.mkdir()
        gh = bindir / "gh"
        gh.write_text(STUB)
        gh.chmod(gh.stat().st_mode | stat.S_IEXEC)

        env = dict(os.environ)
        env["PATH"] = f"{bindir}:{env['PATH']}"
        env["STUB_DIR"] = str(d)
        env["REPO"] = REPO
        env["GH_TOKEN"] = "x"

        proc = subprocess.run(["bash", "-c", self.script], env=env,
                              capture_output=True, text=True)
        self.calls = (d / "calls.log").read_text() if (d / "calls.log").exists() else ""
        self.assertEqual(proc.returncode, 0,
                         f"script exited {proc.returncode}: {proc.stderr}")
        return proc.stdout + proc.stderr

    @classmethod
    def setUpClass(cls):
        cls.script = workflow_script()

    def assert_skipped(self, out, reason):
        self.assertIn(f"skip #305: {reason}", out)
        self.assertNotIn("MERGE pr merge", self.calls)
        self.assertIn("Merged 0 PR(s).", out)

    def assert_merged(self):
        self.assertIn("MERGE pr merge", self.calls)
        self.assertIn(f"--match-head-commit {SHA}", self.calls)

    # -- the regression itself -------------------------------------------

    def test_script_does_not_use_jq_e(self):
        # `gh --jq` has no -e mode; the old form silently broke three gates.
        self.assertNotIn("--jq -e", self.script)

    def test_stub_rejects_the_old_jq_e_invocation(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        gh = pathlib.Path(tmp.name) / "gh"
        gh.write_text(STUB)
        gh.chmod(0o755)
        proc = subprocess.run(
            ["bash", str(gh), "api", "repos/x/y/pulls/1/files",
             "--jq", "-e", "length == 1"],
            env={**os.environ, "STUB_DIR": tmp.name},
            capture_output=True, text=True)
        self.assertNotEqual(proc.returncode, 0)
        self.assertIn("accepts 1 arg(s), received 2", proc.stderr)

    # -- happy paths ------------------------------------------------------

    def test_all_gates_green_merges_with_cas(self):
        out = self.run_script()
        self.assert_merged()
        self.assertIn("merge #305: all gates green", out)
        self.assertIn("Merged 1 PR(s).", out)

    def test_sync_pr_of_added_casks_is_allowed(self):
        self.run_script(
            candidates=[candidate(branch="sync/20261027")],
            files=[{"status": "added", "filename": "Casks/new-cask.rb"}])
        self.assert_merged()

    # -- blocked or malformed labels --------------------------------------

    def test_blocklist_label_blocks(self):
        out = self.run_script(labels=["automerge-skip"])
        self.assert_skipped(out, "blocklist label present")

    def test_do_not_merge_label_blocks(self):
        out = self.run_script(labels=["do not merge"])
        self.assert_skipped(out, "blocklist label present")

    def test_label_query_failure_fails_closed(self):
        out = self.run_script(fail=["fail.labels"])
        self.assert_skipped(out, "could not read labels")

    def test_malformed_label_payload_fails_closed(self):
        out = self.run_script(malformed=["labels"])
        self.assert_skipped(out, "label payload malformed")

    # -- diff scope -------------------------------------------------------

    def test_extra_file_blocks(self):
        out = self.run_script(files=[
            {"status": "modified", "filename": "Casks/zenmap.rb"},
            {"status": "modified", "filename": "README.md"}])
        self.assert_skipped(out, "diff is not exactly one modified Casks/*.rb")

    def test_non_cask_single_file_blocks(self):
        out = self.run_script(files=[
            {"status": "modified", "filename": ".github/workflows/ci.yml"}])
        self.assert_skipped(out, "diff is not exactly one modified Casks/*.rb")

    def test_sync_pr_with_a_modified_file_blocks(self):
        out = self.run_script(
            candidates=[candidate(branch="sync/20261027")],
            files=[{"status": "added", "filename": "Casks/new-cask.rb"},
                   {"status": "modified", "filename": "Casks/old-cask.rb"}])
        self.assert_skipped(out, "diff is not only added Casks/*.rb files")

    def test_file_query_failure_fails_closed(self):
        out = self.run_script(fail=["fail.files"])
        self.assert_skipped(out, "could not read PR files")

    def test_empty_file_list_fails_closed(self):
        out = self.run_script(files=[])
        self.assert_skipped(out, "PR file list empty or malformed")

    # -- check runs -------------------------------------------------------

    def test_missing_critical_context_blocks(self):
        checks = [c for c in healthy_checks() if c["name"] != "audit"]
        out = self.run_script(checks=checks)
        self.assert_skipped(
            out, "CI conclusion, audit, Workflow lint or CodeQL not green on this head")

    def test_critical_context_skipped_is_not_a_pass(self):
        checks = [dict(c) for c in healthy_checks()]
        checks[[c["name"] for c in checks].index("conclusion")]["conclusion"] = "skipped"
        out = self.run_script(checks=checks)
        self.assert_skipped(
            out, "CI conclusion, audit, Workflow lint or CodeQL not green on this head")

    def test_critical_context_failed_blocks(self):
        checks = [dict(c) for c in healthy_checks()]
        checks[[c["name"] for c in checks].index("audit")]["conclusion"] = "failure"
        out = self.run_script(checks=checks)
        self.assert_skipped(out, "a check run failed, was cancelled or needs action")

    def test_action_required_on_any_context_blocks(self):
        checks = healthy_checks() + [check("Kilo Code Review", conclusion="action_required")]
        out = self.run_script(checks=checks)
        self.assert_skipped(out, "a check run failed, was cancelled or needs action")

    def test_pending_check_blocks(self):
        checks = healthy_checks()[:-1] + [check("CodeRabbit", status="in_progress")]
        out = self.run_script(checks=checks)
        self.assert_skipped(out, "a check run is not completed")

    def test_check_query_failure_fails_closed(self):
        out = self.run_script(fail=["fail.checks"])
        self.assert_skipped(out, "could not read check runs")

    def test_empty_check_payload_fails_closed(self):
        out = self.run_script(checks=[])
        self.assert_skipped(out, "check-run payload empty or malformed")

    # -- other preconditions ---------------------------------------------

    def test_not_mergeable_blocks(self):
        out = self.run_script(mergeable="CONFLICTING")
        self.assert_skipped(out, "not mergeable right now")

    def test_no_candidates_is_a_no_op(self):
        out = self.run_script(candidates=[])
        self.assertIn("No candidate bump PRs.", out)
        self.assertNotIn("MERGE pr merge", self.calls)


if __name__ == "__main__":
    unittest.main()
