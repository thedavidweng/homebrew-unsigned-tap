cask "far2l" do
  # NOTE: "2" is not a version number, but an intrinsic part of the product name
  version "2.9.1"
  sha256 "8489df2415c75f7865afecaab1deae6518186306ca7e4afb5d40bf05939842ab"

  url "https://github.com/elfmz/far2l/releases/download/v_#{version}/far2l-#{version}-beta-MacOS-11.2-universal.dmg"
  name "far2l"
  desc "Unix fork of FAR Manager v2"
  homepage "https://github.com/elfmz/far2l"

  livecheck do
    url :url
    regex(/v?(\d+(?:\.\d+)+(?:\w)*)/i)
    strategy :github_latest
  end

  depends_on :macos

  app "far2l.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/far2l.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Saved Application State/com.far2l.savedState"
end
