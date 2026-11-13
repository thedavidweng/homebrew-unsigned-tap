cask "nuclear" do
  arch arm: "aarch64", intel: "x64"

  version "1.55.0"
  sha256 arm:   "b1dd1851319cc5fffbddcf81aae4945a7ef9639392c18a4457e9a2a587bbaa6e",
         intel: "071ea8d49450b70ada76792eec0aca3d664caa18d932f17a3de8bb291af7efb6"

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
