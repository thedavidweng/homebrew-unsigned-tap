cask "universal-gcode-platform" do
  arch arm: "aarch64", intel: "x64"

  version "2.1.30"
  sha256 arm:   "00ef8e7b5150021120f7474248ced802e716a9ae6544210b24a20e9d75f22038",
         intel: "d0ce829b031c217b7cc3dbe9952c18b84258593a5f39b3e9ee18aec094761c56"

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
