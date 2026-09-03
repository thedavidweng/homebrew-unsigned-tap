cask "ankama" do
  version "3.15.2"
  sha256 :no_check

  url "https://launcher.cdn.ankama.com/installers/production/Ankama%20Launcher-Setup.dmg"
  name "Ankama Launcher"
  desc "Video game launcher"
  homepage "https://www.ankama.com/en/launcher"

  livecheck do
    url "https://launcher.cdn.ankama.com/installers/production/latest-mac.yml"
    strategy :electron_builder
  end

  auto_updates true
  depends_on :macos

  app "Ankama Launcher.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall quit: "Ankama Launcher"

  zap trash: [
    "~/Library/Application Support/Ankama Launcher",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.ankama.zaap.sfl*",
    "~/Library/Preferences/com.ankama.zaap.plist",
    "~/Library/Saved Application State/com.ankama.zaap.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
