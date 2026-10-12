import importlib.util
import json
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("autobump", Path(__file__).resolve().parents[1] / "scripts/autobump.py")
autobump = importlib.util.module_from_spec(spec)
spec.loader.exec_module(autobump)
REPO = "thedavidweng/homebrew-unsigned-tap"


def result(version, outdated=True):
    return [{"cask": "sample", "version": {"latest": version, "outdated": outdated}}]


def pr(number=1, branch="bump-sample-1.0", author="github-actions[bot]", repo=REPO):
    return {"number": number, "user": {"login": author}, "head": {"repo": {"full_name": repo}, "ref": branch}}


class AutobumpTests(unittest.TestCase):
    def test_equal_architectures(self):
        self.assertEqual(autobump.plan({"arm": result("2.0"), "intel": result("2.0")}),
                         [("sample", "2.0", ["--version=2.0"])])

    def test_architecture_versions_remain_distinct(self):
        self.assertEqual(autobump.plan({"arm": result("4.0,20261011-0414,abc"), "intel": result("4.0,20261011-0412,abc")})[0][2],
                         ["--version-arm=4.0,20261011-0414,abc", "--version-intel=4.0,20261011-0412,abc"])

    def test_single_architecture_does_not_update_other(self):
        self.assertEqual(autobump.plan({"arm": result("2.0"), "intel": result("1.0", False)}),
                         [("sample", "2.0-arm-only", ["--version-arm=2.0"])])

    def test_no_downgrade_after_version_format_changes(self):
        self.assertEqual(autobump.plan({"arm": result("2.8.1", False), "intel": result("2.8.1", False)}), [])

    def test_livecheck_errors_fail(self):
        with self.assertRaises(ValueError):
            autobump.plan({"arm": [{"status": "error", "messages": ["Unable to get versions"]}]})

    @patch.object(autobump, "channel_coverage", return_value={"arm", "intel"})
    @patch.object(autobump, "output")
    def test_matches_actual_cask_and_preserves_user_imports(self, output, coverage):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        candidates = [pr(), pr(author="human"), pr(repo="human/fork"), pr(branch="sync/20261011")]
        self.assertEqual(autobump.pending_prs("sample", candidates, REPO, "/tap", "main", {"arm", "intel"}),
                         ([(pr(), {"arm", "intel"})], set()))
        coverage.assert_called_once()

    @patch.object(autobump, "channel_coverage")
    @patch.object(autobump, "output")
    def test_import_and_prefix_collision_are_not_updates(self, output, coverage):
        for files in ([{"filename": "Casks/sample.rb", "status": "added"}],
                      [{"filename": "Casks/sample-extra.rb", "status": "modified"}]):
            output.return_value = json.dumps([files])
            self.assertEqual(autobump.pending_prs("sample", [pr()], REPO, "/tap", "main", {"arm"}), ([], {"arm"}))
        coverage.assert_not_called()

    @patch.object(autobump, "channel_coverage", side_effect=[{"arm"}, {"intel"}])
    @patch.object(autobump, "output")
    def test_independent_architecture_prs_are_preserved(self, output, coverage):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        candidates = [pr(), pr(2, "bump-sample-2.0")]
        pending, uncovered = autobump.pending_prs("sample", candidates, REPO, "/tap", "main", {"arm", "intel"})
        self.assertEqual(pending, [(candidates[0], {"arm"}), (candidates[1], {"intel"})])
        self.assertEqual(uncovered, set())

    @patch.object(autobump, "channel_coverage", return_value={"arm"})
    @patch.object(autobump, "output")
    def test_overlapping_updates_require_review(self, output, coverage):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        with self.assertRaisesRegex(ValueError, "review channel coverage"):
            autobump.pending_prs("sample", [pr(), pr(2)], REPO, "/tap", "main", {"arm"})

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output", side_effect=["/tap", json.dumps([[pr()]])])
    @patch.object(autobump, "pending_prs", side_effect=[([], {"arm", "intel"}), ([(pr(), {"arm", "intel"})], set())])
    def test_fresh_candidate_dispatches_checks(self, pending, output, run, chdir):
        autobump.bump("sample", ["--version=2.0"], [], REPO, "main")
        calls = [c.args for c in run.call_args_list]
        self.assertIn(("brew", "bump-cask-pr", "--no-fork", "--version=2.0", "thedavidweng/unsigned-tap/sample"), calls)
        self.assertIn(("gh", "workflow", "run", "ci.yml", "--repo", REPO, "--ref", "bump-sample-1.0", "-f", "casks=sample", "-f", "skip_install=true"), calls)

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_prs", side_effect=[([(pr(), {"arm"})], {"intel"}), ([(pr(2, "bump-sample-intel"), {"intel"})], set())])
    def test_refresh_dispatches_new_head_and_keeps_uncovered_intel_version(self, pending, output, run, chdir):
        output.side_effect = ["/tap", "old-head", json.dumps(result("4.0")), "new-head", json.dumps([[pr(2, "bump-sample-intel")]])]
        autobump.bump("sample", ["--version-arm=3.0", "--version-intel=2.0"], [], REPO, "main")
        calls = [c.args for c in run.call_args_list]
        self.assertIn(("brew", "bump-cask-pr", "--write-only", "--commit", "--version-arm=4.0", "thedavidweng/unsigned-tap/sample"), calls)
        self.assertIn(("brew", "bump-cask-pr", "--no-fork", "--version-intel=2.0", "thedavidweng/unsigned-tap/sample"), calls)
        self.assertIn(("gh", "workflow", "run", "ci.yml", "--repo", REPO, "--ref", "bump-sample-1.0", "-f", "casks=sample", "-f", "skip_install=true"), calls)
        self.assertIn(("gh", "workflow", "run", "ci.yml", "--repo", REPO, "--ref", "bump-sample-intel", "-f", "casks=sample", "-f", "skip_install=true"), calls)
        self.assertFalse(any("--force" in c for c in calls))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_prs", return_value=([(pr(), {"arm"})], set()))
    def test_unchanged_pending_head_does_not_push_or_create_pr(self, pending, output, run, chdir):
        output.side_effect = ["/tap", "same-head", json.dumps(result("2.0", False)), "same-head"]
        autobump.bump("sample", ["--version-arm=2.0"], [], REPO, "main")
        self.assertFalse(any(c.args[0] in ("brew", "gh") or c.args[:2] == ("git", "push") for c in run.call_args_list))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_prs", return_value=([(pr(), {"arm"})], set()))
    def test_livecheck_failure_does_not_push(self, pending, output, run, chdir):
        output.side_effect = ["/tap", "old-head", json.dumps([{"status": "error"}])]
        with self.assertRaises(ValueError):
            autobump.bump("sample", ["--version-arm=2.0"], [], REPO, "main")
        self.assertFalse(any(c.args[:2] == ("git", "push") for c in run.call_args_list))


if __name__ == "__main__":
    unittest.main()
