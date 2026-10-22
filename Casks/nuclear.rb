cask "nuclear" do
  arch arm: "aarch64", intel: "x64"

  version "1.51.2"
  sha256 arm:   "bf157d7d91d0f09b7be9727f389ee52d14f8e548158fcac62445f85bad9d212e",
         intel: "7a0a5698109363a42d8b0e7628bb7ad3d2e02bbb3b35b20ad87f6fe8f46f33f0"

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
