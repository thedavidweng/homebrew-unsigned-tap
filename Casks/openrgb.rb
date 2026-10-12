cask "openrgb" do
  arch arm: "ARM64", intel: "Intel"

  version "1.0,81bbe18"
  sha256 arm:   "ee5e5da7cfa5d79b6604b81d791e3a7a7f2941025ca5de59d974d7a04d498be0",
         intel: "65e9c704eb0fd4ff941c08b183123fe7f9376ca82b5e2ae1f164abe55214fec8"

  url "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_#{version.csv.first}/OpenRGB_#{version.csv.first}_MacOS_#{arch}_#{version.csv.second}.zip"
  name "OpenRGB"
  desc "Open source RGB lighting control that doesn't depend on manufacturer software"
  homepage "https://openrgb.org/"

  livecheck do
    url "https://openrgb.org/releases.html"
    regex(/href=.*?OpenRGB[._-]v?(\d+(?:\.\d+)+)[._-]MacOS[._-]#{arch}[._-](\h+)\.zip/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| "#{match[0]},#{match[1]}" }
    end
  end

  depends_on :macos

  app "OpenRGB.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/OpenRGB.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.config/OpenRGB",
    "~/Library/Preferences/com.yourcompany.OpenRGB.plist",
    "~/Library/Saved Application State/com.yourcompany.OpenRGB.savedState",
  ]
end
