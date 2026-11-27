cask "logisim-evolution" do
  arch arm: "aarch64", intel: "x86_64"

  version "5.1.0"
  sha256 arm:   "6a4a41115b9e348c5bdee88d1744bbad97e5fa8a3d80fc8bee5722bc9c580ed8",
         intel: "bc4c3e5ab6d9c46856990c54d4841923cb6b6788f039d4d8e5f7b8aa6ae38e74"

  url "https://github.com/logisim-evolution/logisim-evolution/releases/download/v#{version}/Logisim-evolution-#{version}-#{arch}.dmg"
  name "Logisim Evolution"
  desc "Digital logic designer and simulator"
  homepage "https://github.com/logisim-evolution/logisim-evolution"

  depends_on :macos

  app "Logisim-evolution.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Logisim-evolution.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Preferences/com.cburch.logisim.plist"
end
