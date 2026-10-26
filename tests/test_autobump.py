import contextlib
import importlib.util
import io
import json
import os
import runpy
import sys
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

    def test_livecheck_error_skips_only_that_cask(self):
        data = {
            "arm": [
                {"status": "error", "cask": "broken", "messages": ["curl: (22) 503"]},
                {"cask": "healthy", "version": {"latest": "2.0", "outdated": True}},
            ],
            "intel": [
                {"status": "error", "cask": "broken", "messages": ["curl: (22) 503"]},
                {"cask": "healthy", "version": {"latest": "2.0", "outdated": True}},
            ],
        }
        self.assertEqual(autobump.plan(data), [("healthy", "2.0", ["--version=2.0"])])
        self.assertEqual([e["cask"] for e in autobump.livecheck_errors(data)], ["broken", "broken"])

    def test_plan_cli_survives_total_livecheck_failure(self):
        import tempfile
        data = [{"status": "error", "cask": "broken", "messages": ["boom"]}]
        with tempfile.TemporaryDirectory() as tmp:
            for arch in ("arm", "intel"):
                Path(tmp, f"outdated-casks-{arch}.json").write_text(json.dumps(data))
            old_argv, old_cwd = sys.argv, os.getcwd()
            os.chdir(tmp)
            try:
                sys.argv = ["autobump.py", "plan"]
                with contextlib.redirect_stdout(io.StringIO()) as out:
                    runpy.run_path(
                        str(Path(__file__).resolve().parents[1] / "scripts/autobump.py"),
                        run_name="__main__")
            finally:
                sys.argv = old_argv
                os.chdir(old_cwd)
            self.assertEqual(out.getvalue(), "")

    def test_partial_architecture_error_skips_the_cask(self):
        data = {
            "arm": [{"cask": "sample", "version": {"latest": "2.0", "outdated": True}}],
            "intel": [{"status": "error", "cask": "sample", "messages": ["timeout"]}],
        }
        self.assertEqual(autobump.plan(data), [])

    @patch.object(autobump, "channel_coverage", return_value={"arm", "intel"})
    @patch.object(autobump, "output")
    def test_matches_actual_cask_and_preserves_user_imports(self, output, coverage):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        candidates = [pr(), pr(author="human"), pr(repo="human/fork"), pr(branch="sync/20261011")]
        self.assertEqual(autobump.pending_prs("sample", candidates, REPO, "/tap", "main", {"arm", "intel"}),
                         ([(pr(), {"arm", "intel"})], set()))
        coverage.assert_called_once()

    @patch.object(autobump, "channel_coverage", return_value={"arm", "intel"})
    @patch.object(autobump, "output")
    def test_pat_authored_pr_matches(self, output, coverage):
        output.return_value = json.dumps([[{"filename": "Casks/sample.rb", "status": "modified"}]])
        owner_pr = pr(2, "bump-sample-2.0", author="thedavidweng")
        self.assertEqual(autobump.pending_prs("sample", [owner_pr], REPO, "/tap", "main", {"arm", "intel"}),
                         ([(owner_pr, {"arm", "intel"})], set()))

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
    @patch.object(autobump, "output", side_effect=["/tap", json.dumps(result("2.0")), json.dumps(result("2.0")), json.dumps([[pr()]])])
    @patch.object(autobump, "pending_prs", side_effect=[([], {"arm", "intel"}), ([(pr(), {"arm", "intel"})], set())])
    @patch.object(autobump, "bump_cask_pr", return_value=True)
    def test_fresh_candidate_relies_on_pr_ci_without_dispatch(self, bump, pending, output, run, chdir):
        autobump.bump("sample", ["--version=2.0"], [], REPO, "main")
        self.assertIn(("--no-fork", "--version=2.0", "thedavidweng/unsigned-tap/sample"),
                      [c.args for c in bump.call_args_list])
        calls = [c.args for c in run.call_args_list]
        self.assertFalse(any(c[:2] == ("gh", "workflow") for c in calls))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_prs", side_effect=[([(pr(), {"arm"})], {"intel"}), ([(pr(2, "bump-sample-intel"), {"intel"})], set())])
    @patch.object(autobump, "bump_cask_pr", return_value=True)
    def test_refresh_pushes_new_head_and_keeps_uncovered_intel_version(self, bump, pending, output, run, chdir):
        output.side_effect = ["/tap", "old-head", json.dumps(result("4.0")), "new-head", json.dumps(result("2.0")), json.dumps([[pr(2, "bump-sample-intel")]])]
        autobump.bump("sample", ["--version-arm=3.0", "--version-intel=2.0"], [], REPO, "main")
        bumped = [c.args for c in bump.call_args_list]
        self.assertIn(("--write-only", "--commit", "--version-arm=4.0", "thedavidweng/unsigned-tap/sample"), bumped)
        self.assertIn(("--no-fork", "--version-intel=2.0", "thedavidweng/unsigned-tap/sample"), bumped)
        calls = [c.args for c in run.call_args_list]
        self.assertTrue(any(c[:2] == ("git", "push") for c in calls))
        self.assertFalse(any(c[:2] == ("gh", "workflow") for c in calls))
        self.assertFalse(any("--force" in c for c in calls))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output")
    @patch.object(autobump, "pending_prs", side_effect=[([], {"arm", "intel"}), ([(pr(), {"arm", "intel"})], set())])
    @patch.object(autobump, "bump_cask_pr", return_value=True)
    def test_catchup_attempts_explicit_version_despite_blind_livecheck(self, bump, pending, output, run, chdir):
        output.side_effect = ["/tap", json.dumps(result("2.0", False)), json.dumps(result("2.0", False)),
                              json.dumps([[pr()]])]
        autobump.bump("sample", ["--version=9.9"], [], REPO, "main", source="catchup")
        self.assertIn(("--no-fork", "--version=9.9", "thedavidweng/unsigned-tap/sample"),
                      [c.args for c in bump.call_args_list])

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output", side_effect=["/tap", json.dumps(result("2.0", False)), json.dumps(result("2.0", False))])
    @patch.object(autobump, "pending_prs", return_value=([], {"arm", "intel"}))
    @patch.object(autobump, "bump_cask_pr", return_value=False)
    def test_catchup_download_failure_opens_nothing(self, bump, pending, output, run, chdir):
        autobump.bump("sample", ["--version=9.9"], [], REPO, "main", source="catchup")
        bumped = [c.args for c in bump.call_args_list]
        self.assertEqual(bumped, [("--no-fork", "--version=9.9", "thedavidweng/unsigned-tap/sample")])
        self.assertEqual(output.call_count, 3)

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output", side_effect=["/tap", json.dumps(result("2.0", False)), json.dumps(result("2.0", False))])
    @patch.object(autobump, "pending_prs", return_value=([], {"arm", "intel"}))
    def test_update_merged_during_scan_does_not_create_duplicate(self, pending, output, run, chdir):
        autobump.bump("sample", ["--version=2.0"], [], REPO, "main")
        calls = [c.args for c in run.call_args_list]
        self.assertIn(("git", "merge", "--ff-only", "origin/main"), calls)
        self.assertFalse(any(c[0] in ("brew", "gh") for c in calls))

    @patch.object(autobump.os, "chdir")
    @patch.object(autobump, "run")
    @patch.object(autobump, "output", side_effect=["/tap", json.dumps(result("3.0")), json.dumps(result("2.0", False)), json.dumps([[pr()]])])
    @patch.object(autobump, "pending_prs", side_effect=[([], {"arm", "intel"}), ([(pr(), {"arm"})], set())])
    @patch.object(autobump, "bump_cask_pr", return_value=True)
    def test_fresh_release_and_architecture_replace_stale_scan_versions(self, bump, pending, output, run, chdir):
        autobump.bump("sample", ["--version=2.0"], [], REPO, "main")
        self.assertIn(("--no-fork", "--version-arm=3.0", "thedavidweng/unsigned-tap/sample"),
                      [c.args for c in bump.call_args_list])
        self.assertEqual(pending.call_args_list[-1].args[-1], {"arm"})

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


class ChannelCoverageTests(unittest.TestCase):
    BASE = 'cask "sample" do\n  version "1.0"\n  sha256 "' + "a" * 64 + '"\n  url "https://example.com/#{version}.zip"\nend'

    def coverage(self, head):
        def execute(*args):
            if args[0] == "brew":
                # Reproduce the macOS 26 runner even on a newer development host.
                script = args[3].replace("< MacOS.version", '< MacOSVersion.new("26")')
                return autobump.subprocess.check_output((*args[:3], script, *args[4:]), text=True)
            if args[3] == "merge-base":
                return "base"
            return self.BASE if args[4].startswith("base:") else head
        with patch.object(autobump, "run"), patch.object(autobump, "output", side_effect=execute):
            return autobump.channel_coverage(pr(), "sample", "/tap", "main")

    def test_future_arm_update_is_pending_on_tahoe_runner(self):
        head = self.BASE.replace("\nend", '\n  on_arm do\n    on_golden_gate :or_newer do\n      version "2.0"\n    end\n  end\nend')
        self.assertEqual(self.coverage(head), {"arm"})

    def test_intel_pin_is_covered_even_when_version_is_unchanged(self):
        head = self.BASE.replace("\nend", '\n  on_intel do\n    livecheck do\n      skip "Last Intel release"\n    end\n  end\nend')
        self.assertEqual(self.coverage(head), {"intel"})

    def test_old_os_only_update_stays_separate(self):
        head = self.BASE.replace("\nend", '\n  on_monterey :or_older do\n    version "2.0"\n  end\nend')
        self.assertEqual(self.coverage(head), set())


if __name__ == "__main__":
    unittest.main()


class BumpCaskPrTests(unittest.TestCase):
    def test_prerelease_only_result_is_skipped(self):
        from types import SimpleNamespace
        proc = SimpleNamespace(returncode=1, stdout="", stderr="152.0.7977.169 is a GitHub pre-release.")
        with patch.object(autobump.subprocess, "run", return_value=proc):
            self.assertFalse(autobump.bump_cask_pr("--no-fork", "sample"))

    def test_unrelated_bump_failure_still_raises(self):
        import subprocess
        from types import SimpleNamespace
        proc = SimpleNamespace(returncode=1, args=("brew", "bump-cask-pr"), stdout="", stderr="download failed")
        with patch.object(autobump.subprocess, "run", return_value=proc):
            with self.assertRaises(subprocess.CalledProcessError):
                autobump.bump_cask_pr("--no-fork", "sample")
