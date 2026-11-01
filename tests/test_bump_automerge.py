"""Gate tests for the bump auto-merge workflow.

The script under test is the real `run:` block of
`.github/workflows/bump-automerge.yml`, extracted from the YAML byte-for-byte
and executed against a stub `gh` on PATH. The stub models the real CLI,
including the fact that `--jq` takes exactly one argument and has no `-e` mode,
so a regression to `--jq -e` shows up here instead of only in production.

Nothing here may reach a real repository. The harness therefore:

- builds the environment from scratch. `GH_TOKEN`, `GITHUB_TOKEN` and the
  enterprise variants are absent, and `HOME`/`GH_CONFIG_DIR`/`XDG_CONFIG_HOME`
  point inside the sandbox, so no ambient credential or gh config is visible;
- asserts that `gh` resolves to the stub before the production script runs, so
  a PATH mistake fails the test rather than reaching the network;
- answers only the calls the script is known to make and rejects anything else
  with a distinct exit code, so a new or unexpected invocation cannot silently
  succeed;
- runs the *production* candidate filter verbatim (`jq` is given the real
  `--jq` argument) instead of restating the predicate in the test;
- captures `gh pr merge` into the call log instead of performing it. Write
  commands are neutralised by the stub, never by rewriting the script text.

Most cases assert the PR is *not* merged: the script must fail closed when the
labels, the diff, the candidate set, or the check runs are missing, malformed,
or bad.
"""

import json
import os
import pathlib
import shutil
import stat
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/bump-automerge.yml"
REPO = "thedavidweng/homebrew-unsigned-tap"
OWNER = "thedavidweng"
SHA = "45c3f67c5571a0e89b2f31edaa4f346e0cb3f8e9"

# Exit codes the stub uses for states the tests must never mistake for success.
EXIT_UNKNOWN_CALL = 91
EXIT_CREDENTIAL_PRESENT = 90

STUB = r"""#!/usr/bin/env bash
set -u
DIR="${STUB_DIR:?}"
printf 'gh %s\n' "$*" >>"$DIR/calls.log"

# No real credentials may be reachable through this stub.
for var in GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN; do
  if [[ -n "${!var:-}" ]]; then
    printf 'stub: %s is set; the harness must not carry real credentials\n' "$var" >&2
    exit 90
  fi
done

unknown() {
  printf 'stub: unexpected invocation: %s\n' "$*" >&2
  exit 91
}

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
  shift 2
  jqv=""; saw_jq=0; paginate=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --jq)       jqv="$2"; saw_jq=1; shift 2 ;;
      --paginate) paginate=1; shift ;;
      --repo|--state|--limit|--json|--search|--base|--head|--label)
                    shift 2 ;;
      *)          shift ;;
    esac
  done
  [[ -e "$DIR/fail.prlist" ]] && exit 1
  # Run the production filter exactly as given; the test never restates it.
  if [[ -e "$DIR/malformed.candidates" ]]; then
    echo '{"message":"oops"}'
    exit 0
  fi
  if [[ "$saw_jq" == 1 ]]; then
    jq -r "$jqv" "$DIR/candidates.json" || exit 1
  else
    cat "$DIR/candidates.json"
  fi
  exit 0
fi

if [[ "${1:-}" == "pr" && "${2:-}" == "view" ]]; then
  mode=""; jqv=""; saw_jq=0
  shift 2
  shift  # PR number
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json) mode="$2"; shift 2 ;;
      --jq)   jqv="$2"; saw_jq=1; shift 2 ;;
      --repo) shift 2 ;;
      *)      shift ;;
    esac
  done
  if [[ "$mode" == "mergeable" ]]; then
    if [[ -e "$DIR/fail.mergeable-with-output" ]]; then
      echo MERGEABLE
      exit 1
    fi
    [[ -e "$DIR/fail.mergeable" ]] && exit 1
    if [[ -e "$DIR/mergeable-sequence.json" ]]; then
      count=0
      [[ -e "$DIR/mergeable-count" ]] && read -r count < "$DIR/mergeable-count"
      value="$(jq --argjson n "$count" '{mergeable: (.[$n] // .[-1])}' "$DIR/mergeable-sequence.json")" || exit 1
      if [[ "$saw_jq" == 1 ]]; then jq -r "$jqv" <<<"$value" || exit 1
      else printf '%s\n' "$value"; fi
      printf '%s\n' "$((count + 1))" > "$DIR/mergeable-count"
      exit 0
    fi
    if [[ "$saw_jq" == 1 ]]; then jq -r "$jqv" "$DIR/mergeable.json"
    else cat "$DIR/mergeable.json"; fi
    exit 0
  fi
  if [[ "$mode" == "labels" ]]; then
    [[ -e "$DIR/fail.labels" ]] && exit 1
    if [[ -e "$DIR/malformed.labels" ]]; then echo "oops"; exit 0; fi
    if [[ "$saw_jq" == 1 ]]; then jq -r "$jqv" "$DIR/labels.object.json"
    else cat "$DIR/labels.object.json"; fi
    exit 0
  fi
  unknown "$*"
fi

if [[ "${1:-}" == "api" ]]; then
  url="${2:-}"; shift 2
  paginate=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --paginate) paginate=1; shift ;;
      --jq|--cache|--header) shift 2 ;;
      *) shift ;;
    esac
  done
  if [[ "$url" == *"/files" ]]; then
    [[ -e "$DIR/fail.files" ]] && exit 1
    cat "$DIR/files.json"
    if [[ "$paginate" == 1 && -e "$DIR/files.page2.json" ]]; then
      echo
      cat "$DIR/files.page2.json"
    fi
    exit 0
  fi
  if [[ "$url" == *"/check-runs"* ]]; then
    # Pagination is honoured explicitly: without --paginate only page 1 is
    # emitted, which is exactly the truncation the workflow must not rely on.
    if [[ -e "$DIR/malformed.checks" ]]; then echo "oops"; exit 0; fi
    [[ -e "$DIR/fail.checks" ]] && exit 1
    cat "$DIR/checks.object.json"
    if [[ "$paginate" == 1 && -e "$DIR/checks.page2.json" ]]; then
      echo
      if [[ -e "$DIR/malformed.checkspage2" ]]; then echo "oops"
      else cat "$DIR/checks.page2.json"; fi
    fi
    exit 0
  fi
  unknown "$*"
fi

if [[ "${1:-}" == "pr" && "${2:-}" == "merge" ]]; then
  # Captured, never executed: the harness has no credentials and no network.
  [[ -e "$DIR/fail.merge" ]] && { echo "stub: merge refused" >&2; exit 1; }
  printf 'MERGE-CAPTURED %s\n' "$*" >>"$DIR/calls.log"
  exit 0
fi

unknown "$*"
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


def candidate(number=305, branch="bump-zenmap-7.993", sha=SHA, **overrides):
    row = {
        "number": number,
        "headRefName": branch,
        "headRefOid": sha,
        "headRepository": {"nameWithOwner": REPO},
        "baseRefName": "main",
        "author": {"login": OWNER},
        "isDraft": False,
    }
    row.update(overrides)
    return row


class AutomergeGateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.script = workflow_script()

    def run_script(self, expect_rc=0, **scenario):
        """Run the real workflow script against the stub; return its output."""
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        d = pathlib.Path(tmp.name)

        sandbox_home = d / "home"
        sandbox_home.mkdir()
        (d / "candidates.json").write_text(
            json.dumps(scenario.get("candidates", [candidate()])))
        (d / "mergeable.json").write_text(
            json.dumps({"mergeable": scenario.get("mergeable", "MERGEABLE")}))
        if "mergeable_sequence" in scenario:
            (d / "mergeable-sequence.json").write_text(
                json.dumps(scenario["mergeable_sequence"]))
        (d / "labels.object.json").write_text(json.dumps(
            {"labels": [{"name": n} for n in scenario.get("labels", [])]}))
        (d / "files.json").write_text(json.dumps(scenario.get("files", [
            {"status": "modified", "filename": "Casks/zenmap.rb"}])))
        (d / "checks.object.json").write_text(json.dumps(
            {"check_runs": scenario.get("checks", healthy_checks())}))
        if "checks_page2" in scenario:
            (d / "checks.page2.json").write_text(
                json.dumps({"check_runs": scenario["checks_page2"]}))
        if "files_page2" in scenario:
            (d / "files.page2.json").write_text(
                json.dumps(scenario["files_page2"]))
        for flag in scenario.get("fail", []):
            (d / flag).write_text("")
        for flag in scenario.get("malformed", []):
            (d / f"malformed.{flag}").write_text("")

        bindir = d / "bin"
        bindir.mkdir()
        gh = bindir / "gh"
        gh.write_text(STUB)
        gh.chmod(gh.stat().st_mode | stat.S_IEXEC)
        sleep = bindir / "sleep"
        sleep.write_text('#!/usr/bin/env bash\nexit 0\n')
        sleep.chmod(sleep.stat().st_mode | stat.S_IEXEC)

        # A clean environment: no inherited gh auth, no inherited gh config.
        env = {
            "PATH": ":".join([str(bindir), str(pathlib.Path(shutil.which("jq")).parent),
                              str(pathlib.Path(shutil.which("bash")).parent),
                              "/usr/bin", "/bin"]),
            "HOME": str(sandbox_home),
            "GH_CONFIG_DIR": str(d / "ghconfig"),
            "XDG_CONFIG_HOME": str(d / "xdg"),
            "STUB_DIR": str(d),
            "REPO": REPO,
            "LC_ALL": "C",
        }
        for var in ("GH_TOKEN", "GITHUB_TOKEN", "GH_ENTERPRISE_TOKEN",
                    "GITHUB_ENTERPRISE_TOKEN"):
            env.pop(var, None)

        # The only `gh` this environment can reach must be the stub.
        resolved = subprocess.run(["bash", "-c", "command -v gh"], env=env,
                                  capture_output=True, text=True)
        self.assertEqual(resolved.stdout.strip(), str(gh),
                         "harness: gh did not resolve to the stub")
        self.assertTrue(os.access(gh, os.X_OK))

        proc = subprocess.run(["bash", "-c", self.script], env=env,
                              capture_output=True, text=True)
        log = d / "calls.log"
        self.calls = log.read_text() if log.exists() else ""
        self.assertEqual(proc.returncode, expect_rc,
                         f"script exited {proc.returncode}: {proc.stderr}")
        self.assertNotIn("stub: unexpected invocation", proc.stderr)
        self.assertNotIn("stub: ", proc.stderr.replace("stub: merge refused", ""))
        return proc.stdout + proc.stderr

    # -- helpers ----------------------------------------------------------

    def merged_numbers(self):
        return [int(line.split()[-1]) for line in self.calls.splitlines()
                if line.startswith("MERGE-CAPTURED")]

    def assert_skipped(self, out, reason, number=305):
        self.assertIn(f"skip #{number}: {reason}", out)
        self.assertEqual(self.merged_numbers(), [])
        self.assertIn("Merged 0 PR(s).", out)

    def assert_merged(self, number=305):
        self.assertEqual(self.merged_numbers(), [number])
        self.assertIn(f"--match-head-commit {SHA}", self.calls)

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

    # -- candidate selection, using the production filter ------------------

    def test_production_filter_admits_only_bot_or_owner_bump_and_sync(self):
        rows = [
            candidate(number=401, branch="bump-ok-1.0"),                  # allow
            candidate(number=402, branch="sync/20261027"),                # allow
            candidate(number=403, branch="bump-foreign-1.0",
                      headRepository={"nameWithOwner": "someone/fork"}),   # foreign repo
            candidate(number=404, branch="bump-stranger-1.0",
                      author={"login": "stranger"}),                      # untrusted author
            candidate(number=405, branch="bump-draft-1.0", isDraft=True),  # draft
            candidate(number=406, branch="bump-other-base-1.0",
                      baseRefName="release"),                             # not main
            candidate(number=407, branch="feature/thing"),                # not bump/sync
            candidate(number=408, branch="dependabot/npm_and_yarn/x"),    # not bump/sync
        ]
        out = self.run_script(candidates=rows)
        # That the script even evaluated a row is decided by the production
        # filter: `=== #<n>` is printed only for admitted candidates. #402 is
        # then legitimately skipped by its own diff gate (a sync PR with a
        # modified file), which is a different decision from scope.
        self.assertIn("=== #401", out)
        self.assertIn("=== #402", out)
        for excluded in (403, 404, 405, 406, 407, 408):
            self.assertNotIn(f"=== #{excluded} ", out)
            self.assertNotIn(f"skip #{excluded}:", out)
        self.assertIn(401, self.merged_numbers())

    def test_candidate_read_failure_merges_nothing(self):
        out = self.run_script(expect_rc=1, fail=["fail.prlist"])
        self.assertEqual(self.merged_numbers(), [])
        self.assertIn("Could not read candidate PRs; merging nothing.", out)

    def test_candidate_payload_not_an_array_merges_nothing(self):
        out = self.run_script(expect_rc=1, malformed=["candidates"])
        # A malformed payload must not be read as "no candidates, all good".
        self.assertIn("not an array", out)
        self.assertEqual(self.merged_numbers(), [])

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

    def test_second_page_failure_is_not_hidden(self):
        # Page 1 is entirely healthy; the only bad context is on page 2. The
        # run must still see it, so per_page truncation cannot fail open.
        out = self.run_script(
            checks=healthy_checks(),
            checks_page2=[check("test late-cask (macos-26, arm)",
                                conclusion="failure")])
        self.assert_skipped(out, "a check run failed, was cancelled or needs action")

    def test_malformed_second_page_fails_closed(self):
        out = self.run_script(checks=healthy_checks(),
                              malformed=["checkspage2"],
                              checks_page2=[])
        self.assert_skipped(out, "could not read check runs")

    # -- other preconditions ---------------------------------------------

    def test_not_mergeable_blocks(self):
        out = self.run_script(mergeable="CONFLICTING")
        self.assert_skipped(out, "not mergeable right now")

    def test_unknown_mergeability_is_retried(self):
        self.run_script(mergeable_sequence=["UNKNOWN", "MERGEABLE"])
        self.assertEqual(self.merged_numbers(), [305])
        self.assertEqual(self.calls.count("--json mergeable"), 2)

    def test_unknown_mergeability_remains_fail_closed(self):
        out = self.run_script(mergeable_sequence=["UNKNOWN"])
        self.assert_skipped(out, "not mergeable right now")
        self.assertEqual(self.calls.count("--json mergeable"), 5)

    def test_mergeability_query_failure_is_not_retried(self):
        out = self.run_script(fail=["fail.mergeable"])
        self.assert_skipped(out, "not mergeable right now")
        self.assertEqual(self.calls.count("--json mergeable"), 1)

    def test_failed_mergeability_query_output_is_not_trusted(self):
        out = self.run_script(fail=["fail.mergeable-with-output"])
        self.assert_skipped(out, "not mergeable right now")

    def test_cas_rejection_is_not_counted_as_merged(self):
        out = self.run_script(fail=["fail.merge"])
        self.assert_skipped(out, "merge rejected (head moved or not permitted)")

    def test_no_candidates_is_a_no_op(self):
        out = self.run_script(candidates=[])
        self.assertIn("No candidate bump PRs.", out)
        self.assertEqual(self.merged_numbers(), [])


if __name__ == "__main__":
    unittest.main()
