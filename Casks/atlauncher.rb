cask "atlauncher" do
  version "3.4.41.3"
  sha256 "a59339a09d2714ebf908c777d7bfb5a4cc2efe768b8dc0b9e0bb1ba7edc52af8"

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
