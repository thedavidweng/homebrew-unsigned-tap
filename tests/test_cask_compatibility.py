import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/check_cask_compatibility.rb"


def cask(extra=""):
    return f'''cask "sample" do
  version "1.0"
  sha256 "{"a" * 64}"
  url "https://example.com/sample.dmg"
  {extra}
  app "Sample.app"
end
'''


class CompatibilityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "Casks").mkdir()
        self.git("init", "-q")

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.root, text=True).strip()

    def check_change(self, before, after):
        path = self.root / "Casks/sample.rb"
        path.write_text(before)
        self.git("add", "Casks/sample.rb")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "base")
        base = self.git("rev-parse", "HEAD")
        path.write_text(after)
        self.git("add", "Casks/sample.rb")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "update")
        head = self.git("rev-parse", "HEAD")
        return subprocess.run(["brew", "ruby", str(SCRIPT), base, head], cwd=self.root,
                              env={**os.environ, "HOMEBREW_NO_AUTO_UPDATE": "1"},
                              capture_output=True, text=True)

    def test_rejects_raised_macos_floor(self):
        result = self.check_change(cask("depends_on macos: :sequoia"), cask("depends_on macos: :tahoe"))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("sequoia / arm", result.stderr)
        self.assertIn("sequoia / intel", result.stderr)

    def test_rejects_architecture_specific_loss(self):
        result = self.check_change(cask("depends_on :macos"), cask("depends_on arch: :arm64"))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("tahoe / intel", result.stderr)
        self.assertNotIn("tahoe / arm", result.stderr)

    def test_preserves_legacy_version_channel(self):
        before = cask("depends_on macos: :sequoia")
        after = cask('''on_sequoia :or_older do
    version "1.0"
    depends_on macos: :sequoia
  end
  on_tahoe :or_newer do
    version "2.0"
    depends_on macos: :tahoe
  end''')
        result = self.check_change(before, after)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_lost_nested_os_channel(self):
        before = cask("depends_on macos: :sequoia")
        after = '''cask "sample" do
  version "2.0"
  sha256 "''' + "a" * 64 + '''"
  url "https://example.com/sample.dmg"
  on_tahoe :or_newer do
    app "Sample.app"
  end
end
'''
        result = self.check_change(before, after)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("sequoia / arm", result.stderr)
        self.assertNotIn("tahoe / arm", result.stderr)

    def test_rejects_missing_revision(self):
        result = subprocess.run(["brew", "ruby", str(SCRIPT), "missing", "HEAD"], cwd=self.root,
                                capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)


if __name__ == "__main__":
    unittest.main()
