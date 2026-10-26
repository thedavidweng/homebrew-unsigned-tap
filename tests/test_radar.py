import importlib.util
import json
import pathlib
import tempfile
import unittest
from unittest.mock import patch

ROOT = pathlib.Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("radar", ROOT / "scripts/radar.py")
radar = importlib.util.module_from_spec(spec)
spec.loader.exec_module(radar)


class RadarTests(unittest.TestCase):
    def test_body_lists_every_signal(self):
        body = radar.build_body(
            "2026-10-26",
            dead=[{"token": "gone", "url": "https://x", "detail": "404"}],
            missing=["vanished"],
            catchups=[("stuck", "9.9")],
            inflight=[(12, "sample 2.0")],
            errors={"flaky": ["timeout", "404"]},
        )
        for needle in ("`gone` — 404", "`vanished`", "`stuck` → 9.9",
                       "#12 sample 2.0", "`flaky` — timeout; 404"):
            self.assertIn(needle, body)

    def test_body_says_none_when_clean(self):
        body = radar.build_body("2026-10-26", [], [], [], [], {})
        self.assertNotIn("- `", body)
        self.assertEqual(body.count("None."), 5)

    def test_missing_upstream_skips_retired_and_present(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = pathlib.Path(tmp)
            tap = base / "tap"
            tap.mkdir()
            (tap / "gone.rb").write_text("x")
            (tap / "retired.rb").write_text("x")
            (tap / "kept.rb").write_text("x")
            self.assertEqual(radar.missing_upstream(tap, {"kept"}, {"retired"}), ["gone"])

    def test_retired_tokens_come_from_sync_blocklist(self):
        self.assertIn("v2ray-unofficial", radar.retired_tokens())

    def test_evidence_prefers_successful_runs(self):
        import io
        import zipfile

        def fake_gh(*args, repo=None):
            self.assertEqual(args[0], "api")
            self.assertIsNone(repo)
            if "/actions/artifacts?" in args[1]:
                return json.dumps({"artifacts": [
                    {"id": 9, "expired": False, "workflow_run": {"id": 2}},
                    {"id": 8, "expired": False, "workflow_run": {"id": 1}},
                    {"id": 7, "expired": True, "workflow_run": {"id": 2}}]})
            return json.dumps({"workflow_runs": [
                {"id": 1, "conclusion": "failure"},
                {"id": 2, "conclusion": "success"}]})

        payload = json.dumps({"arm": [{"status": "error", "cask": "x",
                                       "messages": ["boom"]}]}).encode()
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w") as archive:
            archive.writestr("outdated-casks.json", payload)

        with patch.object(radar, "gh", side_effect=fake_gh), \
                patch.object(radar.subprocess, "run") as run, \
                tempfile.TemporaryDirectory() as tmp:
            run.return_value = unittest.mock.Mock(returncode=0, stdout=buf.getvalue())
            self.assertEqual(radar.livecheck_errors("o/r", tmp), {"x": ["boom"]})
            self.assertTrue(any("artifacts/9/zip" in arg for arg in run.call_args.args[0]))

    def test_upsert_creates_edits_or_closes(self):
        with patch.object(radar, "gh", return_value=json.dumps([])) as gh, \
                patch.object(radar, "gh_create_with_body", return_value="http://x/1") as create:
            radar.upsert_issue("o/r", "body", clean=False)
            create.assert_called_once()
            self.assertIn("create", create.call_args.args[0])

        with patch.object(radar, "gh", return_value=json.dumps([{"number": 7}])), \
                patch.object(radar, "gh_create_with_body") as create:
            radar.upsert_issue("o/r", "body", clean=False)
            self.assertIn("edit", create.call_args.args[0])

        with patch.object(radar, "gh", return_value=json.dumps([{"number": 7}])) as gh:
            radar.upsert_issue("o/r", "body", clean=True)
            self.assertIn("close", gh.call_args.args)


if __name__ == "__main__":
    unittest.main()
