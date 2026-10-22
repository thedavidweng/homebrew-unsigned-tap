cask "openrgb" do
  arch arm: "ARM64", intel: "Intel"

  version "1.1,8e16de2"
  sha256 arm:   "b370d3365eaae8b6a9217e7d1b1ffd5fb6ddffaaff3395fd3cac3673df83191f",
         intel: "5b30d3c97bced335a40593319cb4c045f1ad818a0e0ddefd92350a695a7a6fc4"

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
