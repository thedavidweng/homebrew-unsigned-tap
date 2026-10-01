import importlib.util
import pathlib
import re
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT_PATH = ROOT / "scripts" / "fix_quarantine_targets.py"

OLD_BLOCK = (
    "  postflight_steps do\n"
    '    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]\n'
    "  end\n"
)


def load_module():
    if not SCRIPT_PATH.exists():
        raise AssertionError(f"missing script: {SCRIPT_PATH}")

    spec = importlib.util.spec_from_file_location("fix_quarantine_targets", SCRIPT_PATH)
    if spec is None or spec.loader is None:
        raise AssertionError(f"unable to load script: {SCRIPT_PATH}")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def cask(body):
    return f'cask "probe" do\n  version "1.0.0"\n\n{body}\nend\n'


class FixQuarantineTargetsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = load_module()

    def test_targets_appdir_for_plain_app(self):
        text = cask(f'  app "Probe.app"\n\n{OLD_BLOCK}')
        out, changed = self.mod.transform(text)
        self.assertTrue(changed)
        self.assertIn("{{appdir}}/Probe.app", out)
        self.assertNotIn("{{staged_path}}", out)

    def test_honours_target_key(self):
        # The installed name is the target, not the staged source name.
        text = cask(f'  app "Thorium.app", target: "Thorium Browser.app"\n\n{OLD_BLOCK}')
        self.assertEqual(self.mod.app_names(text), ["Thorium Browser.app"])
        out, _ = self.mod.transform(text)
        self.assertIn("{{appdir}}/Thorium Browser.app", out)

    def test_strips_staged_subdirectory(self):
        # `app "mac/todometer.app"` is moved out by basename.
        text = cask(f'  app "mac/todometer.app"\n\n{OLD_BLOCK}')
        self.assertEqual(self.mod.app_names(text), ["todometer.app"])
        out, _ = self.mod.transform(text)
        block = re.search(r"  postflight_steps do.*?  end\n", out, re.S).group(0)
        self.assertIn("{{appdir}}/todometer.app", block)
        self.assertNotIn("mac/", block)

    def test_multiple_unconditional_apps_get_one_call_each(self):
        text = cask('  app "One.app"\n  app "Two.app"\n  app "Three.app"\n\n' + OLD_BLOCK)
        out, changed = self.mod.transform(text)
        self.assertTrue(changed)
        self.assertEqual(out.count('run "/usr/bin/xattr"'), 3)
        for name in ("One.app", "Two.app", "Three.app"):
            self.assertIn(f"{{{{appdir}}}}/{name}", out)

    def test_nested_alternatives_do_not_produce_bogus_paths(self):
        # `app` stanzas inside on_macos / on_arm blocks are mutually exclusive
        # alternatives; a literal path cannot be built from `#{arch}`.
        text = cask(
            '  on_arm do\n    app "mac-arm/todometer.app"\n  end\n'
            '  on_intel do\n    app "mac-intel/todometer.app"\n  end\n\n' + OLD_BLOCK
        )
        out, changed = self.mod.transform(text)
        self.assertTrue(changed)
        # Same basename in both branches, so exactly one path results.
        self.assertEqual(out.count('run "/usr/bin/xattr"'), 1)
        self.assertIn("{{appdir}}/todometer.app", out)

    def test_skips_names_needing_ruby_interpolation(self):
        # A steps block may only carry literal arguments; Cask/InstallSteps
        # rejects `#{}`, so the staged-path step is left in place.
        for name in (
            "3DGence Slicer #{version.csv.second}.app",
            "OSCAR#{version.major_minor.no_dots}.app",
            "#{folder}mpv.app",
        ):
            text = cask(f'  app "{name}"\n\n{OLD_BLOCK}')
            out, changed = self.mod.transform(text)
            self.assertFalse(changed, f"{name} should be left alone")
            self.assertIn("{{staged_path}}", out)

    def test_skips_pkg_only_casks(self):
        text = cask('  pkg "Probe.pkg"\n\n  uninstall pkgutil: "com.probe"\n\n' + OLD_BLOCK)
        out, changed = self.mod.transform(text)
        self.assertFalse(changed)
        self.assertIn("{{staged_path}}", out)

    def test_skips_binary_only_casks(self):
        # binary symlinks out of the staged directory, so staged_path is right.
        text = cask(f'  binary "probe"\n\n{OLD_BLOCK}')
        out, changed = self.mod.transform(text)
        self.assertFalse(changed)
        self.assertIn("{{staged_path}}", out)

    def test_matches_block_with_must_succeed(self):
        text = cask(
            '  app "Probe.app"\n\n  postflight_steps do\n'
            '    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"],'
            " must_succeed: false\n  end\n"
        )
        out, changed = self.mod.transform(text)
        self.assertTrue(changed)
        self.assertIn("{{appdir}}/Probe.app", out)

    def test_is_idempotent(self):
        text = cask(f'  app "Probe.app"\n\n{OLD_BLOCK}')
        once, _ = self.mod.transform(text)
        twice, changed = self.mod.transform(once)
        self.assertFalse(changed)
        self.assertEqual(once, twice)

    def test_sets_must_succeed_false(self):
        # A path that does not exist makes xattr exit non-zero, which would
        # otherwise abort the install.
        text = cask(f'  app "Probe.app"\n\n{OLD_BLOCK}')
        out, _ = self.mod.transform(text)
        self.assertIn("must_succeed: false", out)


if __name__ == "__main__":
    unittest.main()
