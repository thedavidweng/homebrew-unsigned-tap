cask "betterdiscord-installer" do
  version "1.3.0"
  sha256 "85bdd7b44f9624f7740af4d26682f21730c47a643fde009f2ad766afa19356b8"

  url "https://github.com/BetterDiscord/Installer/releases/download/v#{version}/BetterDiscord-Mac.zip"
  name "BetterDiscord"
  desc "Installer for BetterDiscord"
  homepage "https://betterdiscord.app/"


  depends_on :macos
  depends_on cask: "discord"

  app "BetterDiscord.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/BetterDiscord Installer",
    "~/Library/Application Support/BetterDiscord",
    "~/Library/Preferences/app.betterdiscord.installer.plist",
    "~/Library/Saved Application State/app.betterdiscord.installer.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
