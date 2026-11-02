cask "nuclear" do
  arch arm: "aarch64", intel: "x64"

  version "1.54.0"
  sha256 arm:   "b7f5eb4ada23c43db3aa10234cd6a29de87d77cc5de6ec97a0b44ec14bef2b64",
         intel: "7a4d295792db3f7f718c64152d79f61946e06ca7a3e5c80cb3a698857d17464f"

  url "https://github.com/nukeop/nuclear/releases/download/player%40#{version}/Nuclear_#{version}_#{arch}.dmg"
  name "Nuclear"
  desc "Streaming music player"
  homepage "https://nuclearplayer.com/"

  livecheck do
    url :url
    regex(/^(?:player@)?v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on :macos

  app "Nuclear.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Nuclear.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.nuclearplayer",
    "~/Library/Application Support/nuclear",
    "~/Library/Caches/com.nuclearplayer",
    "~/Library/Logs/com.nuclearplayer",
    "~/Library/Logs/nuclear",
    "~/Library/Preferences/nuclear.plist",
    "~/Library/Saved Application State/nuclear.savedState",
    "~/Library/WebKit/com.nuclearplayer",
  ]
end
