cask "atlauncher" do
  version "3.4.43.0"
  sha256 "5fcadec558a5fa7ce277d11285a0fd25bfd54d5071730735b41cb17c3c299662"

  url "https://github.com/ATLauncher/ATLauncher/releases/download/v#{version}/ATLauncher-#{version}.zip"
  name "ATLauncher"
  desc "Minecraft launcher"
  homepage "https://atlauncher.com/"

  depends_on :macos

  app "ATLauncher.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/ATLauncher.app"],
        must_succeed: false
  end

  uninstall quit: "com.atlauncher.App"

  zap trash: [
    "~/Library/Preferences/com.atlauncher.App.plist",
    "~/Library/Saved Application State/com.atlauncher.App.savedState",
  ]
end
