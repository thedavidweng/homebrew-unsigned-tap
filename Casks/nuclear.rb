cask "nuclear" do
  arch arm: "aarch64", intel: "x64"

  version "1.54.1"
  sha256 arm:   "1b12b00b6233da74781fd7047da54d9709299bd8ae39bc0ec05afcfdeac0a83e",
         intel: "3ac9a44c0690da36bd0e588f9c8cc87019a00e740995d7f306f16fb97e37df46"

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
