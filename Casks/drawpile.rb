cask "drawpile" do
  arch arm: "arm64", intel: "x86_64"

  on_big_sur :or_older do
    version "2.2.1"
    sha256 "d4b29c78da9a64eb8a5526c464f9647b48a99b60cace0ce3eaf06a4e484dec60"

    url "https://github.com/drawpile/Drawpile/releases/download/#{version}/Drawpile-#{version}.dmg"

    livecheck do
      skip "Legacy version"
    end

    caveats do
      requires_rosetta
    end
  end
  on_monterey :or_newer do
    version "2.3.1"
    sha256 arm:   "37ee88585585b9149e4dbc679e3a821f785814aaa85054591955e53ef0999fad",
           intel: "09fd02d7bcfb3cffbaab3dca4ef0c51c3fc7d02ca2e59d1ae9bf6642bc6e6de9"

    url "https://github.com/drawpile/Drawpile/releases/download/#{version}/Drawpile-#{version}-#{arch}.dmg"

    livecheck do
      url :url
      strategy :github_latest
    end
  end

  name "Drawpile"
  desc "Collaborative drawing app"
  homepage "https://drawpile.net/"

  depends_on :macos

  app "Drawpile.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Drawpile.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/drawpile",
    "~/Library/Preferences/net.drawpile.drawpile.plist",
    "~/Library/Preferences/net.drawpile.DrawpileClient.plist",
    "~/Library/Saved Application State/net.drawpile.DrawpileClient.savedState",
  ]
end
