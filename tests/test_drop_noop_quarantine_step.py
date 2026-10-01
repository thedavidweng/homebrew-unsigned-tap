import importlib.util
import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "scripts" / "drop_noop_quarantine_step.py"

STEP = (
    "\n  postflight_steps do\n"
    '    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]\n'
    "  end\n"
)


def load_module():
    if not SCRIPT_PATH.exists():
        raise AssertionError(f"missing script: {SCRIPT_PATH}")

    spec = importlib.util.spec_from_file_location("drop_noop_quarantine_step", SCRIPT_PATH)
    if spec is None or spec.loader is None:
        raise AssertionError(f"unable to load script: {SCRIPT_PATH}")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def cask(body):
    return f'cask "probe" do\n  version "1.0.0"\n\n{body}\nend\n'


class DropNoopQuarantineStepTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = load_module()

    def test_drops_step_for_pkg_only_cask(self):
        # macOS installs the payload; Homebrew never propagates quarantine to
        # it, so the step only deleted the attribute from the .pkg itself.
        text = cask('  pkg "Probe.pkg"\n\n  uninstall pkgutil: "com.probe"\n' + STEP)
        out, changed = self.mod.transform(text)
        self.assertTrue(changed)
        self.assertNotIn("xattr", out)
        self.assertNotIn("postflight_steps", out)
        self.assertIn('pkg "Probe.pkg"', out)

    def test_drops_step_for_installer_only_cask(self):
        text = cask('  installer manual: "Probe.app"\n\n  uninstall script: "x"\n' + STEP)
        out, changed = self.mod.transform(text)
        self.assertTrue(changed)
        self.assertNotIn("xattr", out)

    def test_keeps_step_for_binary_cask(self):
        # A binary is symlinked out of the staged directory, so that path is
        # where the file actually lives.
        text = cask(f'  binary "probe"\n{STEP}')
        out, changed = self.mod.transform(text)
        self.assertFalse(changed)
        self.assertIn("{{staged_path}}", out)

    def test_keeps_step_when_pkg_and_binary_are_combined(self):
        # metasploit installs binaries outside the Caskroom via the pkg, but
        # Homebrew's `binary` stanzas still reference them by staged path.
        text = cask('  pkg "probe.pkg"\n  binary "/opt/probe/bin/x"\n' + STEP)
        out, changed = self.mod.transform(text)
        self.assertFalse(changed)
        self.assertIn("{{staged_path}}", out)

    def test_keeps_step_for_app_cask(self):
        # App casks are repointed at {{appdir}} by fix_quarantine_targets.py.
        text = cask(f'  app "Probe.app"\n{STEP}')
        out, changed = self.mod.transform(text)
        self.assertFalse(changed)
        self.assertIn("{{staged_path}}", out)

    def test_is_idempotent(self):
        text = cask('  pkg "Probe.pkg"\n' + STEP)
        once, _ = self.mod.transform(text)
        twice, changed = self.mod.transform(once)
        self.assertFalse(changed)
        self.assertEqual(once, twice)

    def test_leaves_other_stanzas_intact(self):
        text = cask('  pkg "Probe.pkg"\n\n  zap trash: "~/probe"\n' + STEP)
        out, _ = self.mod.transform(text)
        self.assertIn('zap trash: "~/probe"', out)
        self.assertIn('pkg "Probe.pkg"', out)
        self.assertNotIn("xattr", out)

    def test_preserves_trailing_newline(self):
        text = cask('  pkg "Probe.pkg"\n' + STEP)
        out, _ = self.mod.transform(text)
        self.assertTrue(out.endswith("\n"))
        self.assertFalse(out.endswith("\n\n"))


if __name__ == "__main__":
    unittest.main()
