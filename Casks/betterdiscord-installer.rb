cask "betterdiscord-installer" do
  version "2.0.0"
  sha256 "7acd4d8d1408ec2100de7de2a2c19103874e127f9e995bcb46fa06dc809fc5fd"

  url "https://github.com/BetterDiscord/Installer/releases/download/v#{version}/BetterDiscord-Installer-Mac.zip"
  name "BetterDiscord"
  desc "Installer for BetterDiscord"
  homepage "https://betterdiscord.app/"

  depends_on cask: "discord"
  depends_on macos: :monterey

  app "BetterDiscord Installer.app"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: [
    "~/Library/Application Support/BetterDiscord Installer",
    "~/Library/Application Support/BetterDiscord",
    "~/Library/Preferences/app.betterdiscord.installer.plist",
    "~/Library/Saved Application State/app.betterdiscord.installer.savedState",
  ]
end
