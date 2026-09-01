cask "pixel-picker" do
  version "1.6.1"
  sha256 "2c98627f6fca2f3a7d043499e63be25dd80ecd6ab848e15637961f10ebc0bd6f"

  url "https://github.com/acheronfail/pixel-picker/releases/download/#{version}/Pixel.Picker.#{version}.dmg"
  name "Pixel Picker"
  desc "Menu bar application to pick colours from your screen"
  homepage "https://github.com/acheronfail/pixel-picker"


  depends_on :macos

  app "Pixel Picker.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Logs/Pixel Picker",
    "~/Library/Preferences/Pixel Picker",
  ]
end
