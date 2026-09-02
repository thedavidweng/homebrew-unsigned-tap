cask "syncplay" do
  version "1.7.6"
  sha256 "b027d9ba402953db9fe66f2d3770d16e500f1f6ac7e5a5a6e9552310fe9febb7"

  url "https://github.com/Syncplay/syncplay/releases/download/v#{version}/Syncplay_#{version}.dmg"
  name "Syncplay"
  desc "Synchronises media players"
  homepage "https://syncplay.pl/"

  livecheck do
    url :homepage
    regex(/href=.*?Syncplay[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
  end


  depends_on :macos

  app "Syncplay.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.syncplay",
    "~/Library/Preferences/com.syncplay.Interface.plist",
    "~/Library/Preferences/com.syncplay.MainWindow.plist",
    "~/Library/Preferences/com.syncplay.MoreSettings.plist",
    "~/Library/Preferences/com.syncplay.PlayerList.plist",
    "~/Library/Preferences/pl.syncplay.Syncplay.plist",
    "~/Library/Saved Application State/pl.syncplay.Syncplay.savedState",
  ]
end
