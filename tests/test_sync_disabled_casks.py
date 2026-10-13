import contextlib
import importlib.util
import io
import pathlib
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
DISABLED = '''cask "fresh" do
  version "1.0"
  sha256 :no_check
  url "https://example.com/fresh.zip"
  name "Fresh"
  desc "Fresh app"
  homepage "https://example.com/"
  disable! date: "2026-01-01", because: :fails_gatekeeper_check
  app "Fresh.app"
end
'''


class SyncTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        base = pathlib.Path(self.temp.name)
        self.src, self.dest = base / "upstream", base / "tap"
        self.src.mkdir()
        self.dest.mkdir()
        spec = importlib.util.spec_from_file_location(
            "sync_disabled_casks", ROOT / "scripts/sync_disabled_casks.py"
        )
        self.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.module)
        self.module.SRC_CASK_DIR, self.module.DEST_CASK_DIR = self.src, self.dest

    def run_sync(self, **kwargs):
        with contextlib.redirect_stdout(io.StringIO()):
            self.module.sync_all(**kwargs)

    def test_import_preserves_maintained_bytes_and_only_adds_disabled_casks(self):
        maintained = b"maintained package URL, native requirements and legacy routing\n"
        (self.dest / "existing.rb").write_bytes(maintained)
        (self.src / "existing.rb").write_text(DISABLED.replace("fresh", "existing"))
        (self.src / "fresh.rb").write_text(DISABLED)
        (self.src / "healthy.rb").write_text(DISABLED.replace("fresh", "healthy").replace(
            '  disable! date: "2026-01-01", because: :fails_gatekeeper_check\n', ""
        ))
        self.run_sync()
        self.assertEqual((self.dest / "existing.rb").read_bytes(), maintained)
        self.assertEqual({p.name for p in self.dest.iterdir()}, {"existing.rb", "fresh.rb"})
        imported = (self.dest / "fresh.rb").read_text()
        self.assertNotIn("disable!", imported)
        self.assertIn("preflight_steps", imported)
        self.assertNotIn("postflight_steps", imported)
        before = {p.name: p.read_bytes() for p in self.dest.iterdir()}
        self.run_sync()
        self.assertEqual({p.name: p.read_bytes() for p in self.dest.iterdir()}, before)

    def test_quarantine_runs_before_moved_plugin_payload(self):
        imported = self.module.transform_content(DISABLED.replace('app "Fresh.app"', 'screen_saver "Fresh.saver"'))
        self.assertIn('preflight_steps do', imported)
        self.assertNotIn('postflight_steps do', imported)

    def test_merges_into_existing_preflight_without_duplicate_block(self):
        source = DISABLED.replace('end\n', '  preflight_steps do\n    move_contents ".", "Fresh"\n  end\nend\n')
        imported = self.module.transform_content(source)
        self.assertEqual(imported.count('preflight_steps do'), 1)
        self.assertIn('move_contents', imported)
        self.assertIn('com.apple.quarantine', imported)
        self.assertLess(imported.index('com.apple.quarantine'), imported.index('move_contents'))
        self.assertIn('on_macos do', imported)

    def test_limit_does_not_overwrite_existing_definition(self):
        (self.src / "existing.rb").write_text(DISABLED.replace("fresh", "existing"))
        (self.dest / "existing.rb").write_text("maintained\n")
        self.run_sync(limit_files=["existing"])
        self.assertEqual((self.dest / "existing.rb").read_text(), "maintained\n")

    def test_dry_run_does_not_write_new_definition(self):
        (self.src / "fresh.rb").write_text(DISABLED)
        self.run_sync(dry_run=True)
        self.assertEqual(list(self.dest.iterdir()), [])

    def test_retired_cask_is_not_reimported(self):
        token = next(iter(self.module.DEAD_CASKS))
        (self.src / (token + ".rb")).write_text(DISABLED.replace("fresh", token))
        self.run_sync()
        self.assertEqual(list(self.dest.iterdir()), [])


if __name__ == "__main__":
    unittest.main()
