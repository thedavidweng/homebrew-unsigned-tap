cask "atlauncher" do
  version "3.4.41.2"
  sha256 "55600fe80d5033e0783ce4286fe85b760112a93ae0a70c5258715c71ca026755"

  url "https://github.com/ATLauncher/ATLauncher/releases/download/v#{version}/ATLauncher-#{version}.zip"
  name "ATLauncher"
  desc "Minecraft launcher"
  homepage "https://atlauncher.com/"


  depends_on :macos

  app "ATLauncher.app"

  uninstall quit: "com.atlauncher.App"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Preferences/com.atlauncher.App.plist",
    "~/Library/Saved Application State/com.atlauncher.App.savedState",
  ]
end
