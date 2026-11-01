import importlib.util
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = pathlib.Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "upstream_catchup", ROOT / "scripts/upstream_catchup.py")
catchup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(catchup)
def cask(version="1.0", livecheck=None, extra=""):
    block = "" if livecheck is None else f"\n  livecheck do\n{livecheck}\n  end\n"
    return (f'cask "sample" do\n  version "{version}"\n  sha256 "abc"\n'
            f'  url "https://example.com/{version}.zip"\n{extra}{block}end\n')


class CatchupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        base = pathlib.Path(self.temp.name)
        self.tap, self.src = base / "tap", base / "upstream"
        self.tap.mkdir()
        self.src.mkdir()

    def write_pair(self, token, ours, theirs):
        (self.tap / f"{token}.rb").write_text(ours)
        (self.src / f"{token}.rb").write_text(theirs)

    def upstream(self):
        return catchup.snapshot_upstream(self.src)

    def test_skip_encodes_a_pin_and_is_never_adopted(self):
        self.write_pair("pinned", cask("3.5.1", '    skip "Pinned edition"'), cask("4.7.2"))
        self.assertTrue(catchup.has_livecheck_skip((self.tap / "pinned.rb").read_text()))
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()), [])

    def test_per_os_skip_without_strategy_is_still_a_pin(self):
        body = ('  on_monterey :or_older do\n    livecheck do\n      skip "Old OS"\n    end\n  end\n')
        self.write_pair("oldschool", cask("1.0") + body, cask("2.0"))
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()), [])

    def test_single_version_upstream_newer_is_a_candidate(self):
        self.write_pair("fresh", cask("1.0", '    url :url\n    strategy :github_latest'), cask("2.0"))
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()),
                         [("fresh", "1.0", "2.0")])

    def test_equal_multi_and_latest_versions_are_ignored(self):
        self.write_pair("same", cask("1.0"), cask("1.0"))
        self.write_pair("multi", cask("1.0", extra='  on_arm do\n    version "1.0-arm"\n  end\n'), cask("2.0"))
        (self.tap / "rolling.rb").write_text('cask "rolling" do\n  version :latest\nend\n')
        (self.src / "rolling.rb").write_text('cask "rolling" do\n  version :latest\nend\n')
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()), [])

    def test_latest_with_pinned_arch_is_never_a_single_version(self):
        rolling = 'cask "sample" do\n  version :latest\n  on_intel do\n    version "1.0"\n  end\nend\n'
        self.write_pair("mixed-local", rolling, cask("2.0"))
        self.write_pair("mixed-upstream", cask("1.0"), rolling)
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()), [])
        self.assertIn(":latest", catchup.version_literals(rolling))

    def test_only_restricts_candidates(self):
        self.write_pair("a", cask("1.0"), cask("2.0"))
        self.write_pair("b", cask("1.0"), cask("2.0"))
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), {"a"}), [("a", "1.0", "2.0")])

    def test_candidate_is_not_excluded_by_flattened_open_prs(self):
        self.write_pair("sample", cask("1.0"), cask("2.0"))
        snapshot = pathlib.Path(self.temp.name) / "snapshot.json"
        snapshot.write_text(json.dumps(self.upstream()))
        prs = pathlib.Path(self.temp.name) / "open-cask-prs.json"
        prs.write_text(json.dumps([
            {"number": 1, "head": {"ref": "bump-sample-1.5"}},
            {"number": 2, "head": {"ref": "bump-other-2.0"}},
        ]))
        env = dict(os.environ, TAP_CASK_DIR=str(self.tap), SNAPSHOT_JSON=str(snapshot), OPEN_PRS_JSON=str(prs))
        proc = subprocess.run([sys.executable, str(ROOT / "scripts/upstream_catchup.py")],
                              env=env, capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual(proc.stdout, "sample\t2.0\t--version=2.0\tcatchup\n")

    def test_missing_upstream_is_ignored(self):
        (self.tap / "gone.rb").write_text(cask("1.0"))
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()), [])

    def test_upstream_letter_subdirectory_is_found(self):
        (self.tap / "fresh.rb").write_text(cask("1.0"))
        letter = self.src / "f"
        letter.mkdir()
        (letter / "fresh.rb").write_text(cask("2.0"))
        self.assertEqual(catchup.candidates(self.tap, self.upstream(), set()),
                         [("fresh", "1.0", "2.0")])

    @patch.object(catchup.subprocess, "check_output",
                   return_value="fresh\tNEWER\nstale\tOTHER\nbroken\tERR\n")
    def test_only_strictly_newer_survives_homebrew_comparison(self, _check):
        pairs = [("fresh", "1.0", "2.0"), ("stale", "2.0", "1.0"), ("broken", "1.0", "zzz")]
        self.assertEqual(catchup.upstream_newer(pairs), [("fresh", "2.0")])

    def test_empty_pairs_skip_brew(self):
        with patch.object(catchup.subprocess, "check_output") as check:
            self.assertEqual(catchup.upstream_newer([]), [])
            check.assert_not_called()

    def test_row_marks_catchup_source(self):
        self.assertEqual(catchup.row("sample", "9.9"), "sample\t9.9\t--version=9.9\tcatchup")

    def test_snapshot_script_writes_json(self):
        (self.src / "a.rb").write_text(cask("1.0"))
        out = pathlib.Path(self.temp.name) / "out.json"
        env = dict(os.environ, SRC_CASK_DIR=str(self.src), SNAPSHOT_OUT=str(out))
        proc = subprocess.run([sys.executable, str(ROOT / "scripts/upstream_snapshot.py")],
                              env=env, capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual(json.loads(out.read_text()), {"a": ["1.0"]})

    def test_snapshot_round_trip(self):
        (self.src / "a.rb").write_text(cask("1.0"))
        letter = self.src / "b"
        letter.mkdir()
        (letter / "b.rb").write_text(cask("2.0"))
        (letter / "rolling.rb").write_text('version :latest\non_intel do\n  version "1.0"\nend\n')
        snap = catchup.snapshot_upstream(self.src)
        self.assertEqual(snap, {"a": ["1.0"], "b": ["2.0"], "rolling": [":latest", "1.0"]})
        path = pathlib.Path(self.temp.name) / "snap.json"
        path.write_text(__import__("json").dumps(snap))
        self.assertEqual(catchup.load_snapshot(str(path)), snap)

    def test_snapshot_artifact_version_is_shared_by_producer_and_consumers(self):
        workflows = ROOT / ".github/workflows"
        self.assertIn("name: upstream-versions-v2", (workflows / "sync.yml").read_text())
        for name in ("autobump.yml", "healthcheck.yml"):
            self.assertIn("artifacts?name=upstream-versions-v2&", (workflows / name).read_text())


if __name__ == "__main__":
    unittest.main()
