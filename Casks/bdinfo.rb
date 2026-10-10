cask "bdinfo" do
  version "1.0"
  sha256 :no_check

  url "https://www.videohelp.com/download/BDInfo%20OSX.dmg",
      referer: "https://www.videohelp.com/software/BDInfo"
  name "BDInfo"
  desc "Collect video and audio technical specifications from Blu-ray discs"
  homepage "https://www.videohelp.com/software/BDInfo"

  livecheck do
    skip "Upstream version page returns HTTP 503; manual verification required"
  end

  depends_on :macos

  app "BDInfo OSX.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/BDInfo OSX.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.yourcompany.BDInfo-OSX.plist",
    "~/Library/Saved Application State/com.yourcompany.BDInfo-OSX.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
