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
            failures=["broken"],
            unverified=[{"token": "blocked", "url": "https://x", "detail": "403"}],
        )
        for needle in ("`gone` — 404", "`vanished`", "`stuck` → 9.9",
                       "#12 sample 2.0", "`flaky` — timeout; 404", "`broken`", "`blocked` — 403"):
            self.assertIn(needle, body)

    def test_body_says_none_when_clean(self):
        body = radar.build_body("2026-10-26", [], [], [], [], {}, [], [])
        self.assertNotIn("- `", body)
        self.assertEqual(body.count("None."), 9)

    def test_unavailable_evidence_is_not_reported_as_no_failed_bumps(self):
        body = radar.build_body("2026-10-26", [], [], [], [],
                               {"<evidence unavailable>": "missing"}, None, [])
        self.assertIn("## Failed bumps in latest scheduled autobump\n- evidence unavailable\n", body)
        self.assertEqual(body.count("- evidence unavailable"), 2)

    def test_missing_upstream_skips_retired_and_present(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = pathlib.Path(tmp)
            tap = base / "tap"
            tap.mkdir()
            (tap / "gone.rb").write_text("x")
            (tap / "retired.rb").write_text("x")
            (tap / "kept.rb").write_text("x")
            self.assertEqual(radar.missing_upstream(tap, {"kept"}, {"retired"}), ["gone"])

    def test_catchup_and_inflight_uses_candidate_contract(self):
        with tempfile.TemporaryDirectory() as tmp:
            tap = pathlib.Path(tmp)
            (tap / "sample.rb").write_text('cask "sample" do\n  version "1.0"\nend\n')
            prs = [{"number": 12, "title": "sample 2.0", "headRefName": "bump-sample-2.0"}]
            with patch.object(radar, "TAP_CASK_DIR", tap), patch.object(radar, "gh", return_value=json.dumps(prs)):
                self.assertEqual(radar.catchup_and_inflight("o/r", {"sample": ["2.0"]}),
                                 ([("sample", "2.0")], [(12, "sample 2.0")]))

    def test_classify_catchups_checks_both_architectures(self):
        def result(latest, current="2.23.1", outdated=False):
            return json.dumps([{"cask": "treesheets", "version": {
                "current": current, "latest": latest, "outdated": outdated}}])

        with tempfile.TemporaryDirectory() as tmp:
            tap = pathlib.Path(tmp) / "Casks"
            tap.mkdir()
            (tap / "treesheets.rb").write_text('cask "treesheets" do\n  version "2.23.1"\nend\n')
            with patch.object(radar, "TAP_CASK_DIR", tap), \
                    patch.object(radar.subprocess, "check_output") as check:
                check.side_effect = [tmp, result("2.23.1"), result("2.23.1")]
                confirmed, conflicts, unresolved = radar.classify_catchups([("treesheets", "3333")])
                self.assertEqual(confirmed, [])
                self.assertEqual(conflicts, [("treesheets", "3333",
                                              "arm: 2.23.1 → 2.23.1 (current), "
                                              "intel: 2.23.1 → 2.23.1 (current)")])
                self.assertEqual(unresolved, [])
                self.assertIn("arm", check.call_args_list[1].args[0])
                self.assertIn("intel", check.call_args_list[2].args[0])

                check.side_effect = [tmp, result("2.24.0", outdated=True), result("2.24.0", outdated=True)]
                self.assertEqual(radar.classify_catchups([("treesheets", "2.24.0")]),
                                 ([("treesheets", "2.24.0")], [], []))

                for bad in ("[]", result("2.23.1", current="2.22.5"), "not json"):
                    check.side_effect = [tmp, bad]
                    confirmed, conflicts, unresolved = radar.classify_catchups([("treesheets", "3333")])
                    self.assertEqual((confirmed, conflicts), ([], []))
                    self.assertEqual(unresolved[0][:2], ("treesheets", "3333"))

                check.side_effect = [str(tap)]
                confirmed, conflicts, unresolved = radar.classify_catchups([("treesheets", "3333")])
                self.assertEqual((confirmed, conflicts), ([], []))
                self.assertIn("differs", unresolved[0][2])

    def test_conflicting_upstream_evidence_prevents_clean_close(self):
        with tempfile.TemporaryDirectory() as tmp:
            dead = pathlib.Path(tmp) / "dead.json"
            dead.write_text('{"dead": [], "unverified": []}')
            with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                    patch.object(radar, "DEAD_JSON", str(dead)), \
                    patch.object(radar, "load_upstream", return_value={"treesheets": ["3333"]}), \
                    patch.object(radar, "missing_upstream", return_value=[]), \
                    patch.object(radar, "retired_tokens", return_value=set()), \
                    patch.object(radar, "catchup_and_inflight", return_value=([("treesheets", "3333")], [])), \
                    patch.object(radar, "classify_catchups", return_value=(
                        [], [("treesheets", "3333", "arm: 2.23.1, intel: 2.23.1")], [])), \
                    patch.object(radar, "autobump_evidence", return_value=({}, [])), \
                    patch.object(radar, "upsert_issue") as upsert:
                radar.main()
        self.assertFalse(upsert.call_args.args[2])
        self.assertIn("`treesheets` — upstream 3333; livecheck arm: 2.23.1, intel: 2.23.1",
                      upsert.call_args.args[1])

    def test_retired_tokens_use_sync_blocklist(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            (root / "scripts").mkdir()
            (root / "scripts/sync_disabled_casks.py").write_text('DEAD_CASKS = {"retired"}\n')
            with patch.object(radar, "ROOT", root):
                self.assertEqual(radar.retired_tokens(), {"retired"})

    def test_evidence_reads_latest_successful_scheduled_run(self):
        import io
        import zipfile

        responses = [json.dumps({"workflow_runs": [{"id": 2, "conclusion": "success"}]}),
                     json.dumps({"artifacts": [
                         {"id": 9, "expired": False, "workflow_run": {"id": 2}},
                         {"id": 7, "expired": True, "workflow_run": {"id": 2}}]})]

        payload = json.dumps({"arm": [{"status": "error", "cask": "x",
                                       "messages": ["boom"]}]}).encode()
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w") as archive:
            archive.writestr("outdated-casks.json", payload)
            archive.writestr("bump-failures.txt", "broken\nbroken\n")

        with patch.object(radar, "gh", side_effect=responses) as gh, \
                patch.object(radar.subprocess, "run") as run:
            run.return_value = unittest.mock.Mock(returncode=0, stdout=buf.getvalue())
            self.assertEqual(radar.autobump_evidence("o/r"), ({"x": ["boom"]}, ["broken"]))
            self.assertTrue(any("artifacts/9/zip" in arg for arg in run.call_args.args[0]))
        self.assertEqual(gh.call_args_list, [
            unittest.mock.call("api", "repos/o/r/actions/workflows/autobump.yml/runs?event=schedule&status=completed&per_page=1"),
            unittest.mock.call("api", "repos/o/r/actions/runs/2/artifacts?name=livecheck-casks&per_page=10"),
        ])

    def test_missing_latest_evidence_does_not_use_an_older_run(self):
        responses = [json.dumps({"workflow_runs": [{"id": 2, "conclusion": "success"}]}),
                     json.dumps({"artifacts": []})]
        with patch.object(radar, "gh", side_effect=responses) as gh:
            errors, failures = radar.autobump_evidence("o/r")
        self.assertIn("<evidence unavailable>", errors)
        self.assertIsNone(failures)
        self.assertIn("/actions/runs/2/artifacts?", gh.call_args_list[1].args[1])

    def test_missing_failure_list_is_not_a_clean_run(self):
        import io
        import zipfile

        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w") as archive:
            archive.writestr("outdated-casks.json", json.dumps({
                "arm": [{"status": "error", "cask": "x", "messages": ["boom"]}]
            }))
        responses = [json.dumps({"workflow_runs": [{"id": 2, "conclusion": "success"}]}),
                     json.dumps({"artifacts": [{"id": 9, "expired": False,
                                                "workflow_run": {"id": 2}}]})]
        with patch.object(radar, "gh", side_effect=responses), \
                patch.object(radar.subprocess, "run") as run:
            run.return_value = unittest.mock.Mock(returncode=0, stdout=buf.getvalue())
            errors, failures = radar.autobump_evidence("o/r")
        self.assertEqual(errors, {"x": ["boom"]})
        self.assertIsNone(failures)
        body = radar.build_body("2026-10-26", [], [], [], [], errors, failures, [])
        self.assertIn("## Livecheck errors in latest autobump evidence\n- `x` — boom\n", body)
        self.assertIn("## Failed bumps in latest scheduled autobump\n- evidence unavailable\n", body)

    def test_missing_failure_list_prevents_clean_close(self):
        with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                patch.object(radar, "load_upstream", return_value={}), \
                patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                patch.object(radar, "autobump_evidence", return_value=({}, None)), \
                patch.object(radar, "upsert_issue") as upsert:
            radar.main()
        self.assertFalse(upsert.call_args.args[2])
        self.assertIn("## Failed bumps in latest scheduled autobump\n- evidence unavailable\n",
                      upsert.call_args.args[1])

    def test_missing_livecheck_preserves_failed_bumps(self):
        import io
        import zipfile

        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w") as archive:
            archive.writestr("bump-failures.txt", "broken\n")
        responses = [json.dumps({"workflow_runs": [{"id": 2, "conclusion": "success"}]}),
                     json.dumps({"artifacts": [{"id": 9, "expired": False,
                                                "workflow_run": {"id": 2}}]})]
        with patch.object(radar, "gh", side_effect=responses), \
                patch.object(radar.subprocess, "run") as run:
            run.return_value = unittest.mock.Mock(returncode=0, stdout=buf.getvalue())
            errors, failures = radar.autobump_evidence("o/r")
        self.assertIn("<evidence unavailable>", errors)
        self.assertEqual(failures, ["broken"])
        body = radar.build_body("2026-10-26", [], [], [], [], errors, failures, [])
        self.assertIn("## Livecheck errors in latest autobump evidence\n- evidence unavailable\n", body)
        self.assertIn("## Failed bumps in latest scheduled autobump\n- `broken`\n", body)

    def test_invalid_livecheck_shape_preserves_failed_bumps(self):
        import io
        import zipfile

        for payload in ([], {"arm": None}, {"arm": [None]},
                        {"arm": [{"status": "error", "cask": "x", "messages": "boom"}]}):
            with self.subTest(payload=payload):
                buf = io.BytesIO()
                with zipfile.ZipFile(buf, "w") as archive:
                    archive.writestr("outdated-casks.json", json.dumps(payload))
                    archive.writestr("bump-failures.txt", "broken\n")
                responses = [json.dumps({"workflow_runs": [{"id": 2, "conclusion": "success"}]}),
                             json.dumps({"artifacts": [{"id": 9, "expired": False,
                                                        "workflow_run": {"id": 2}}]})]
                with patch.object(radar, "gh", side_effect=responses), \
                        patch.object(radar.subprocess, "run") as run:
                    run.return_value = unittest.mock.Mock(returncode=0, stdout=buf.getvalue())
                    errors, failures = radar.autobump_evidence("o/r")
                self.assertIn("<evidence unavailable>", errors)
                self.assertEqual(failures, ["broken"])

    def test_empty_livecheck_object_is_valid(self):
        import io
        import zipfile

        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w") as archive:
            archive.writestr("outdated-casks.json", "{}")
            archive.writestr("bump-failures.txt", "")
        responses = [json.dumps({"workflow_runs": [{"id": 2, "conclusion": "success"}]}),
                     json.dumps({"artifacts": [{"id": 9, "expired": False,
                                                "workflow_run": {"id": 2}}]})]
        with patch.object(radar, "gh", side_effect=responses), \
                patch.object(radar.subprocess, "run") as run:
            run.return_value = unittest.mock.Mock(returncode=0, stdout=buf.getvalue())
            self.assertEqual(radar.autobump_evidence("o/r"), ({}, []))

    def test_failed_scheduled_run_is_not_treated_as_complete_evidence(self):
        response = json.dumps({"workflow_runs": [{"id": 2, "conclusion": "failure"}]})
        with patch.object(radar, "gh", return_value=response) as gh, \
                patch.object(radar.subprocess, "run") as run:
            errors, failures = radar.autobump_evidence("o/r")
        self.assertIn("<evidence unavailable>", errors)
        self.assertIsNone(failures)
        gh.assert_called_once_with(
            "api", "repos/o/r/actions/workflows/autobump.yml/runs?event=schedule&status=completed&per_page=1")
        run.assert_not_called()

    def test_failed_bump_prevents_clean_close(self):
        with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                patch.object(radar, "load_upstream", return_value={}), \
                patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                patch.object(radar, "autobump_evidence", return_value=({}, ["broken"])), \
                patch.object(radar, "upsert_issue") as upsert:
            radar.main()
        self.assertFalse(upsert.call_args.args[2])
        self.assertIn("`broken`", upsert.call_args.args[1])

    def test_missing_healthcheck_does_not_close_radar(self):
        with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                patch.object(radar, "DEAD_JSON", ""), \
                patch.object(radar, "load_upstream", return_value={"kept": ["1"]}), \
                patch.object(radar, "missing_upstream", return_value=[]), \
                patch.object(radar, "retired_tokens", return_value=set()), \
                patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                patch.object(radar, "autobump_evidence", return_value=({}, [])), \
                patch.object(radar, "upsert_issue") as upsert:
            radar.main()
        self.assertFalse(upsert.call_args.args[2])
        self.assertIn("## HTTP 404/410 downloads (healthcheck)\n- evidence unavailable\n",
                      upsert.call_args.args[1])

    def test_missing_upstream_does_not_close_radar(self):
        with tempfile.TemporaryDirectory() as tmp:
            dead = pathlib.Path(tmp) / "dead.json"
            dead.write_text('{"dead": [], "unverified": []}')
            with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                    patch.object(radar, "DEAD_JSON", str(dead)), \
                    patch.object(radar, "load_upstream", return_value={}), \
                    patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                    patch.object(radar, "autobump_evidence", return_value=({}, [])), \
                    patch.object(radar, "upsert_issue") as upsert:
                radar.main()
        self.assertFalse(upsert.call_args.args[2])
        body = upsert.call_args.args[1]
        self.assertIn("## Removed upstream, still in this tap\n- evidence unavailable\n", body)
        self.assertIn("still here next week = bump keeps failing)\n- evidence unavailable\n", body)

    def test_empty_complete_evidence_can_close_radar(self):
        with tempfile.TemporaryDirectory() as tmp:
            dead = pathlib.Path(tmp) / "dead.json"
            dead.write_text('{"dead": [], "unverified": []}')
            with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                    patch.object(radar, "DEAD_JSON", str(dead)), \
                    patch.object(radar, "load_upstream", return_value={"kept": ["1"]}), \
                    patch.object(radar, "missing_upstream", return_value=[]), \
                    patch.object(radar, "retired_tokens", return_value=set()), \
                    patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                    patch.object(radar, "autobump_evidence", return_value=({}, [])), \
                    patch.object(radar, "upsert_issue") as upsert:
                radar.main()
        self.assertTrue(upsert.call_args.args[2])
        self.assertEqual(upsert.call_args.args[1].count("None."), 9)

    def test_healthcheck_without_dead_field_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            dead = pathlib.Path(tmp) / "dead.json"
            dead.write_text('{}')
            with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                    patch.object(radar, "DEAD_JSON", str(dead)), \
                    patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                    patch.object(radar, "autobump_evidence", return_value=({}, [])), \
                    patch.object(radar, "upsert_issue") as upsert:
                with self.assertRaises(KeyError):
                    radar.main()
                upsert.assert_not_called()

    def test_unverified_healthcheck_prevents_clean_close(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = pathlib.Path(tmp) / "dead.json"
            report.write_text(json.dumps({"dead": [], "unverified": [
                {"token": "blocked", "url": "https://x", "detail": "403"}]}))
            with patch.dict(radar.os.environ, {"GITHUB_REPOSITORY": "o/r"}), \
                    patch.object(radar, "DEAD_JSON", str(report)), \
                    patch.object(radar, "load_upstream", return_value={"kept": ["1"]}), \
                    patch.object(radar, "missing_upstream", return_value=[]), \
                    patch.object(radar, "retired_tokens", return_value=set()), \
                    patch.object(radar, "catchup_and_inflight", return_value=([], [])), \
                    patch.object(radar, "autobump_evidence", return_value=({}, [])), \
                    patch.object(radar, "upsert_issue") as upsert:
                radar.main()
        self.assertFalse(upsert.call_args.args[2])
        self.assertIn("## Unverified downloads (healthcheck)\n- `blocked` — 403\n",
                      upsert.call_args.args[1])

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
