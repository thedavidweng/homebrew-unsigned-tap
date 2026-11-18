cask "renpy" do
  version "8.6.1"
  sha256 "596c31be88b351de64166276708278a70f24e833be7181e7c37b8c106a0f0fdb"

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
