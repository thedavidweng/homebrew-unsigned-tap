#!/usr/bin/env python3
"""
Rewrite quarantine-removal steps in this tap to target the *installed* location.

Why this exists
---------------
The tap previously stripped quarantine with:

    postflight_steps do
      run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
    end

That is wrong for every cask whose artifact is an `app` or a `pkg`.
`Cask::Artifact::AbstractArtifact#sort_order` runs `App` and `Pkg` *before*
`PostflightSteps`, so by the time the step runs the payload has already been
moved out of the staged directory:

  * `app "Foo.app"` has been moved to /Applications/Foo.app, leaving the staged
    directory holding only a symlink to it, so `xattr -r` on it removes nothing
    and the installed app stays quarantined.
  * `pkg` is installed by macOS /usr/sbin/installer, which likewise empties the
    staged directory.

Only `binary` casks are unaffected: the binary is symlinked from the staged
directory, which still holds the real file.

This script points the step at where the payload actually lands. Target names
are read from each cask's own `app` stanza, honouring `target:`, rather than
being guessed from the token. Casks with several `app` stanzas (per-arch or
per-OS branches) get one `xattr` call per distinct name.

Run it after syncing from upstream; it is idempotent.
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
CASK_DIR = ROOT / "Casks"

# The exact step this script replaces: a postflight_steps block whose only
# content is the staged-path xattr, with or without a trailing
# `must_succeed: false`. Blocks with anything else are left alone.
QUARANTINE_BLOCK = re.compile(
    r"^  postflight_steps do\n"
    r'    run "/usr/bin/xattr", args: \["-r", "-d", "com\.apple\.quarantine", "\{\{staged_path\}\}"\]'
    r"(?:, must_succeed: false)?\n"
    r"  end\n",
    re.M,
)

# An `app` stanza, with an optional `target:`. Only two-space indentation
# counts, i.e. a top-level stanza. Stanzas nested in `on_macos` / `on_arm` /
# macOS-version blocks describe mutually exclusive alternatives — exactly one
# of them installs on any given machine — so listing them all would emit paths
# that never exist. The top-level stanza is the one that applies unconditionally
# where there is one.
APP_STANZA = re.compile(
    r'^  app "(?P<src>[^"]+)"(?P<rest>[^\n]*)$',
    re.M,
)
# Fallback for casks whose only `app` stanzas are nested (e.g. xit, todometer).
NESTED_APP_STANZA = re.compile(
    r'^[ ]+app "(?P<src>[^"]+)"(?P<rest>[^\n]*)$',
    re.M,
)
TARGET = re.compile(r'target:\s*"(?P<target>[^"]+)"')


def app_names(text):
    """Distinct names the installed `.app` can land under, in stanza order.

    Returns None when a name cannot be expressed as a literal steps-block
    argument, i.e. when the `app` stanza interpolates Ruby (`#{}`). A steps
    block may only contain literal arguments — `Cask/InstallSteps` rejects
    Ruby interpolation — and no `{{...}}` token reproduces `version.csv.second`,
    `version.major_minor.no_dots` or a locally computed folder. Those casks
    keep the staged-path step, which is no worse than before.
    """
    matches = list(APP_STANZA.finditer(text)) or list(NESTED_APP_STANZA.finditer(text))
    names = []
    for match in matches:
        target = TARGET.search(match.group("rest"))
        if target:
            name = target.group("target")
        else:
            # `app` takes a path relative to the staged directory and the app
            # is moved out by basename, so `app "mac/todometer.app"` lands at
            # {{appdir}}/todometer.app. The parent directory is not preserved.
            name = match.group("src").rsplit("/", 1)[-1]
        if "#{" in name:
            return None
        if name not in names:
            names.append(name)
    return names


def replacement(names):
    lines = ["  postflight_steps do\n"]
    if len(names) == 1:
        lines.append(
            '    run "/usr/bin/xattr",\n'
            '        args: ["-rd", "com.apple.quarantine", "{{appdir}}/%s"],\n'
            "        must_succeed: false\n" % names[0]
        )
    else:
        # Several apps install unconditionally, so each needs its own call.
        for name in names:
            lines.append(
                '    run "/usr/bin/xattr",\n'
                '        args: ["-rd", "com.apple.quarantine", "{{appdir}}/%s"],\n'
                "        must_succeed: false\n" % name
            )
    lines.append("  end\n")
    return "".join(lines)


def transform(text):
    block = QUARANTINE_BLOCK.search(text)
    if not block:
        return text, False

    names = app_names(text)
    if not names:
        # No `app` stanza (pkg / installer-only: macOS installs those and
        # there is no single path to name), or the name needs Ruby
        # interpolation that a steps block cannot carry. Leave the existing
        # step untouched rather than guess.
        return text, False

    return text[: block.start()] + replacement(names) + text[block.end():], True


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

    print(f"rewrote {len(changed)} cask(s) to target the installed app path")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
