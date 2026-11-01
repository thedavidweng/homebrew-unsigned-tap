import http.server
import json
import pathlib
import subprocess
import tempfile
import threading
import unittest
from unittest.mock import patch

from scripts import check_cask_health as health


class Handler(http.server.BaseHTTPRequestHandler):
    def respond(self):
        if self.path == "/redirect-missing":
            self.send_response(302)
            self.send_header("Location", "/missing")
        elif self.path == "/redirect-ok":
            self.send_response(302)
            self.send_header("Location", "/ok")
        elif self.path == "/ok":
            self.send_response(200)
        elif self.path == "/restricted":
            self.send_response(403)
        elif self.path == "/loop":
            self.send_response(302)
            self.send_header("Location", "/loop")
        elif self.path == "/get-only":
            self.send_response(405 if self.command == "HEAD" else 200)
        else:
            self.send_response(404)
        self.end_headers()

    do_HEAD = respond
    do_GET = respond

    def log_message(self, format, *args):
        pass


class HealthcheckTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.thread.join()
        cls.server.server_close()

    def test_redirect_to_missing_is_not_reachable(self):
        _, _, result, _ = health.check_url_and_fetch("test", self.base + "/redirect-missing")
        self.assertIs(result, False)

    def test_redirect_to_existing_is_reachable(self):
        _, _, result, _ = health.check_url_and_fetch("test", self.base + "/redirect-ok")
        self.assertIs(result, True)

    def test_restricted_download_is_unverified(self):
        _, _, result, _ = health.check_url_and_fetch("test", self.base + "/restricted")
        self.assertIsNone(result)

    def test_redirect_loop_is_unverified(self):
        _, _, result, _ = health.check_url_and_fetch("test", self.base + "/loop")
        self.assertIsNone(result)

    def test_get_when_head_is_not_supported(self):
        _, _, result, _ = health.check_url_and_fetch("test", self.base + "/get-only")
        self.assertIs(result, True)

    def test_failed_curl_with_success_status_is_unverified(self):
        results = [subprocess.CompletedProcess([], 28, "200 1025", "timeout"),
                   subprocess.CompletedProcess([], 0, "404 0", "")]
        with patch.object(health.subprocess, "run", side_effect=results):
            _, _, result, _ = health.check_url_and_fetch("test", "https://example.test")
        self.assertIsNone(result)

    def test_range_ignored_after_successful_partial_response(self):
        results = [subprocess.CompletedProcess([], 0, "405 0", ""),
                   subprocess.CompletedProcess([], 56, "200 1025",
                                               "Exceeded the maximum allowed file size (1025) with 1025 bytes")]
        with patch.object(health.subprocess, "run", side_effect=results):
            _, _, result, _ = health.check_url_and_fetch("test", "https://example.test")
        self.assertIs(result, True)

    def test_size_limit_on_error_page_is_not_success(self):
        results = [subprocess.CompletedProcess([], 0, "204 0", ""),
                   subprocess.CompletedProcess([], 56, "404 1025",
                                               "Exceeded the maximum allowed file size (1025) with 1025 bytes")]
        with patch.object(health.subprocess, "run", side_effect=results):
            _, _, result, _ = health.check_url_and_fetch("test", "https://example.test")
        self.assertIsNone(result)

    def test_curl_failure_retains_http_status(self):
        results = [subprocess.CompletedProcess([], 0, "403 0", ""),
                   subprocess.CompletedProcess([], 56, "403 0", "Maximum file size exceeded")]
        with patch.object(health.subprocess, "run", side_effect=results):
            _, _, result, detail = health.check_url_and_fetch("test", "https://example.test")
        self.assertIsNone(result)
        self.assertEqual(detail, "HEAD: 403; GET: HTTP 403: Maximum file size exceeded")

    def test_homebrew_confirmation_requires_explicit_missing_response(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            (root / "Casks").mkdir()
            installed = root / "Casks" / "test.rb"
            installed.write_text("same cask")
            local = root / "local.rb"
            local.write_text("same cask")
            results = [subprocess.CompletedProcess([], 0, "", ""),
                       subprocess.CompletedProcess([], 1, "", "curl: (22) returned error: 404"),
                       subprocess.CompletedProcess([], 1, "", "connection timed out")]
            with patch.object(health.subprocess, "check_output", return_value=str(root)), \
                    patch.object(health.subprocess, "run", side_effect=results) as run:
                self.assertFalse(health.homebrew_confirms_missing("test", local))
                self.assertTrue(health.homebrew_confirms_missing("test", local))
                self.assertFalse(health.homebrew_confirms_missing("test", local))
                local.write_text("different cask")
                self.assertFalse(health.homebrew_confirms_missing("test", local))
                self.assertEqual(run.call_count, 3)

    def test_delete_does_not_remove_unverified_cask(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            cask = root / "test.rb"
            cask.write_text("cask content")
            report = root / "report.json"
            with patch.object(health, "CASKS_DIR", root), \
                    patch.object(health, "ROOT", root), \
                    patch.object(health, "get_all_cask_urls", return_value={"test": "https://example.test"}), \
                    patch.object(health, "check_url_and_fetch", return_value=("test", "https://example.test", None, "HTTP 403")), \
                    patch("sys.argv", ["check_cask_health", "--delete", "--json-out", str(report)]):
                with self.assertRaises(SystemExit) as exc:
                    health.main()
            self.assertEqual(exc.exception.code, 1)
            self.assertTrue(cask.exists())
            self.assertEqual(json.loads(report.read_text())["unverified"][0]["token"], "test")

    def test_delete_requires_homebrew_confirmation(self):
        for confirmed in (False, True):
            with self.subTest(confirmed=confirmed), tempfile.TemporaryDirectory() as tmp:
                root = pathlib.Path(tmp)
                cask = root / "test.rb"
                cask.write_text("cask content")
                with patch.object(health, "CASKS_DIR", root), \
                        patch.object(health, "ROOT", root), \
                        patch.object(health, "get_all_cask_urls", return_value={"test": "https://example.test"}), \
                        patch.object(health, "check_url_and_fetch", return_value=("test", "https://example.test", False, "404")), \
                        patch.object(health, "homebrew_confirms_missing", return_value=confirmed), \
                        patch("sys.argv", ["check_cask_health", "--delete"]):
                    with self.assertRaises(SystemExit):
                        health.main()
                self.assertEqual(cask.exists(), not confirmed)

    def test_empty_extraction_is_not_all_clear(self):
        with tempfile.TemporaryDirectory() as tmp:
            report = pathlib.Path(tmp) / "report.json"
            with patch.object(health, "get_all_cask_urls", return_value={}), \
                    patch("sys.argv", ["check_cask_health", "--json-out", str(report)]):
                with self.assertRaises(SystemExit):
                    health.main()
            self.assertFalse(report.exists())


if __name__ == "__main__":
    unittest.main()
