cask "renpy" do
  version "8.6.0"
  sha256 "c14e4d3e270edc5c4f1a328d0bda6b4e2fa1bbf86689e8edf51981bee07ecf74"

  url "https://www.renpy.org/dl/#{version}/renpy-#{version}-sdk.zip"
  name "Ren'Py"
  desc "Visual novel engine in Python"
  homepage "https://www.renpy.org/"

  livecheck do
    url "https://www.renpy.org/latest.html"
    regex(/href=.*?renpy[._-]v?(\d+(?:\.\d+)+)[._-]sdk\.dmg/i)
  end

  depends_on :macos

  suite "renpy-#{version}-sdk"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: [
    "~/Library/RenPy",
    "~/Library/Saved Application State/org.renpy.sdk.savedState",
  ]
end
