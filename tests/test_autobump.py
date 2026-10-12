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

    @patch.object(autobump, "output")
    def test_matches_actual_cask_file_not_title_or_version(self, output):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        self.assertEqual(autobump.pending_pr("sample", [pr()], REPO), pr())

    @patch.object(autobump, "output")
    def test_does_not_touch_user_fork_or_sync_import(self, output):
        self.assertIsNone(autobump.pending_pr("sample", [pr(author="human"), pr(repo="human/fork"), pr(branch="sync/20261011")], REPO))
        output.assert_not_called()

    @patch.object(autobump, "output")
    def test_added_cask_and_prefix_collision_are_not_update_prs(self, output):
        for files in ([{"filename": "Casks/sample.rb", "status": "added"}],
                      [{"filename": "Casks/sample-extra.rb", "status": "modified"}]):
            output.return_value = json.dumps([files])
            self.assertIsNone(autobump.pending_pr("sample", [pr()], REPO))

    @patch.object(autobump, "output")
    def test_duplicates_require_coverage_review(self, output):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        with self.assertRaisesRegex(ValueError, "review channel coverage"):
            autobump.pending_pr("sample", [pr(), pr(2, "bump-sample-2.0")], REPO)

    @patch.object(autobump, "run")
    @patch.object(autobump, "pending_pr", return_value=None)
    def test_new_candidate_uses_existing_brew_path(self, pending, run):
        autobump.bump("sample", "2.0", ["--version-arm=2.0"], [], REPO, "main")
        run.assert_called_once_with("brew", "bump-cask-pr", "--no-fork", "--version-arm=2.0", "thedavidweng/unsigned-tap/sample")

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_pr", return_value=pr())
    def test_refresh_rechecks_pending_definition_and_appends_commit(self, pending, output, run, chdir):
        output.side_effect = ["/tap\n", json.dumps(result("3.0")), json.dumps(result("2.0", False))]
        autobump.bump("sample", "2.0", ["--version=2.0"], [], REPO, "main")
        calls = [c.args for c in run.call_args_list]
        self.assertIn(("git", "merge", "--no-edit", "origin/main"), calls)
        self.assertIn(("brew", "bump-cask-pr", "--write-only", "--commit", "--version-arm=3.0", "thedavidweng/unsigned-tap/sample"), calls)
        self.assertIn(("git", "push", "origin", "HEAD:bump-sample-1.0"), calls)
        self.assertFalse(any("--force" in c for c in calls))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_pr", return_value=pr())
    def test_already_current_pending_pr_creates_no_new_pr(self, pending, output, run, chdir):
        output.side_effect = ["/tap\n", json.dumps(result("2.0", False)), json.dumps(result("2.0", False))]
        autobump.bump("sample", "2.0", ["--version=2.0"], [], REPO, "main")
        self.assertFalse(any(c.args[0] == "brew" for c in run.call_args_list))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_pr", return_value=pr())
    def test_pending_livecheck_failure_does_not_push(self, pending, output, run, chdir):
        output.side_effect = ["/tap\n", json.dumps([{"status": "error"}]), "[]"]
        with self.assertRaises(ValueError):
            autobump.bump("sample", "2.0", ["--version=2.0"], [], REPO, "main")
        self.assertFalse(any(c.args[:2] == ("git", "push") for c in run.call_args_list))


if __name__ == "__main__":
    unittest.main()
