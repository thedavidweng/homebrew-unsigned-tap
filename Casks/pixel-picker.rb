cask "pixel-picker" do
  minimum_macos = :big_sur

  on_ventura :or_older do
    version "1.6.1"
    sha256 "2c98627f6fca2f3a7d043499e63be25dd80ecd6ab848e15637961f10ebc0bd6f"

    url "https://github.com/acheronfail/pixel-picker/releases/download/#{version}/Pixel.Picker.#{version}.dmg"

    livecheck do
      skip "Newer releases require macOS Sonoma or later"
    end
  end
  on_sonoma :or_newer do
    version "1.7.1"
    sha256 "31584144fc66cafdcd3d6689a69b9ab311621dbe1ee0713f2820a1a2a271903e"

    url "https://github.com/acheronfail/pixel-picker/releases/download/v#{version}/PixelPicker-#{version}-universal.dmg"
    minimum_macos = :sonoma
  end

  name "Pixel Picker"
  desc "Menu bar application to pick colours from your screen"
  homepage "https://github.com/acheronfail/pixel-picker"

  depends_on macos: minimum_macos

  app "Pixel Picker.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Pixel Picker.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Logs/Pixel Picker",
    "~/Library/Preferences/Pixel Picker",
  ]

  caveats <<~EOS
    When upgrading from 1.6.1 to 1.7.0, upstream requires removing and re-adding
    Pixel Picker in macOS Accessibility and Screen Recording permissions.
  EOS
end
