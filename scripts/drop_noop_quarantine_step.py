#!/usr/bin/env python3
"""
Drop the no-op quarantine step from casks that do not need it.

Why this exists
---------------
This tap stripped quarantine with a `postflight_steps` block pointing at
`{{staged_path}}`. That path is only the right one for a `binary` artifact: a
binary is symlinked out of the staged directory, which still holds the real
file. `scripts/fix_quarantine_targets.py` already repointed the `app` casks at
`{{appdir}}/<name>.app`, where the bundle lands.

That leaves `pkg` and `installer` casks, where the step does nothing at all.
Homebrew quarantines the downloaded `.pkg` itself, but the payload is
installed by macOS `/usr/sbin/installer`, which Homebrew does not drive. The
quarantine attribute is only ever propagated from a container to its extracted
contents, and that happens in `Cask::Download` during extraction
(`Quarantine.propagate` in cask/download.rb), which `pkg` never reaches.

Verified both ways by installing unsigned probe packages through casks:

  * a `pkg` installing a CLI binary  -> installed file had no quarantine
  * a `pkg` installing an .app bundle -> /Applications/<name>.app had no
    quarantine, and `open` launched it with no Gatekeeper block

So the step is dead weight: it deletes the quarantine attribute from the
`.pkg` in the staged directory, which nothing executes. This script removes
it, and only from casks whose artifacts are exclusively `pkg`/`installer`.
Casks that also install a `binary` keep the step, because for those the
staged path really is the installed file.

Run after `sync_disabled_casks.py`; idempotent.
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
CASK_DIR = ROOT / "Casks"

# The exact block to remove, including the blank line that follows it.
QUARANTINE_BLOCK = re.compile(
    r"\n  postflight_steps do\n"
    r'    run "/usr/bin/xattr", args: \["-r", "-d", "com\.apple\.quarantine", "\{\{staged_path\}\}"\]'
    r"(?:, must_succeed: false)?\n"
    r"  end\n",
)

# Artifact stanzas, at any indentation.
ARTIFACT = re.compile(r"^[ ]{0,4}(?P<kind>app|app_image|pkg|binary|artifact|installer|suite|command_wrapper|generated_script|stage_only)\b", re.M)


def artifact_kinds(text):
    return {m.group("kind") for m in ARTIFACT.finditer(text)}


def needs_step(text):
    """True when a `binary` or `app` artifact makes the step meaningful."""
    kinds = artifact_kinds(text)
    return bool(kinds & {"binary", "app"})


def transform(text):
    if not QUARANTINE_BLOCK.search(text):
        return text, False
    if needs_step(text):
        # Installs a binary (staged path is the installed file) or an app
        # (handled by fix_quarantine_targets.py). Leave it alone.
        return text, False

    new_text = QUARANTINE_BLOCK.sub("", text, count=1)
    # Removing the block can leave a doubled blank line behind.
    new_text = re.sub(r"\n{3,}", "\n\n", new_text)
    if not new_text.endswith("\n"):
        new_text += "\n"
    return new_text, True


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    paths = [pathlib.Path(p) for p in argv] if argv else sorted(CASK_DIR.glob("*.rb"))

    changed = []
    for path in paths:
        text = original = path.read_text(encoding="utf-8")
        text, did_change = transform(text)
        if did_change and text != original:
            path.write_text(text, encoding="utf-8")
            changed.append(path.stem)

    print(f"removed the no-op quarantine step from {len(changed)} cask(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
