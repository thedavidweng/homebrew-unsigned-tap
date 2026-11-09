cask "steam-plus-plus" do
  version "3.2.0"
  sha256 "b688605848bc94f6b63a967d6a5bccffff9d462172ced674980ab5e4828d12d8"

  url "https://github.com/BeyondDimension/SteamTools/releases/download/#{version}/Steam++_v#{version}_macos.dmg"
  name "Steam++"
  desc "Steam helper tools"
  homepage "https://steampp.net/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Steam++.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Steam++.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Caches/Steam++",
    "~/Library/Preferences/net.steampp.app.plist",
    "~/Library/Saved Application State/net.steampp.app.savedState",
    "~/Library/Steam++",
  ]
end
