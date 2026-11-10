cask "steam-plus-plus" do
  on_ventura :or_older do
    version "3.1.0"
    sha256 "4016ed6bba5f4eef14ee7da550dff2d29a8d85483af2fcad77ebda02ebc0be7d"

    livecheck do
      skip "Legacy version for macOS Ventura and earlier"
    end

    depends_on macos: :monterey
  end
  on_sonoma :or_newer do
    version "3.2.0"
    sha256 "b688605848bc94f6b63a967d6a5bccffff9d462172ced674980ab5e4828d12d8"

    livecheck do
      url :url
      strategy :github_latest
    end

    depends_on macos: :sonoma
  end

  url "https://github.com/BeyondDimension/SteamTools/releases/download/#{version}/Steam++_v#{version}_macos.dmg"
  name "Steam++"
  desc "Steam helper tools"
  homepage "https://steampp.net/"

  depends_on :macos

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
