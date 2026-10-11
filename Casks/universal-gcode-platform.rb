cask "universal-gcode-platform" do
  arch arm: "aarch64", intel: "x64"

  version "2.1.27"
  sha256 arm:   "19c0dbc7db1c3f5572c78500e1cf1d58291b18d268b0d4519f993f40cea8416f",
         intel: "2205da00008f5c836e8a54e28bc63b1f481aca9003abfa784b6b347ad546da9b"

  url "https://github.com/winder/Universal-G-Code-Sender/releases/download/v#{version}/macosx-#{arch}-ugs-platform-app-#{version}.dmg"
  name "Universal G-code Sender (Platform version)"
  desc "G-code sender for CNC (compatible with GRBL, TinyG, g2core and Smoothieware)"
  homepage "https://winder.github.io/ugs_website/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Universal Gcode Sender.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Universal Gcode Sender.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/ugsplatform",
    "~/Library/Preferences/ugs",
  ]

  caveats <<~EOS
    UGS developers do not sign their code and this app may need manual changes.
    For more information, see:
      https://github.com/winder/Universal-G-Code-Sender/issues/1351#issuecomment-579110056
  EOS
end
