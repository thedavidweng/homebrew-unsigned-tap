cask "via" do
  version "3.0.0"
  sha256 "30f9f81154a8ee9c0cf19f4fb1a3d6ca9a448f765122845db1e190b9f583d16b"

  url "https://github.com/the-via/releases/releases/download/v#{version}/via-#{version}-mac.dmg"
  name "VIA"
  desc "Keyboard configurator"
  homepage "https://caniusevia.com/"

  depends_on :macos

  app "VIA.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/VIA",
    "~/Library/Application Support/via-nativia",
    "~/Library/Logs/VIA",
    "~/Library/Preferences/org.via.configurator.plist",
  ]

  caveats do
    requires_rosetta
  end
end
