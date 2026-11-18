cask "atlauncher" do
  version "3.4.42.0"
  sha256 "b6c59df0a14faaef5b1c315f7043b683240b24efdb9e483ee3a1f68374f11548"

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
