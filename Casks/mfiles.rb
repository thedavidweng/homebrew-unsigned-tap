cask "mfiles" do
  on_big_sur :or_older do
    version "2.5.3,20240328"
    sha256 "ed871abb9876721f6b9e17805147c9afa505851857f1dd88cfeef4a847b59173"

    livecheck do
      skip "Legacy version for macOS Big Sur and earlier"
    end
  end
  on_monterey :or_newer do
    version "2.6.1,2026110601"
    sha256 "5d1b101638c3a8a7fd27e64b7b05f2785fc1af64de5cd2fc8fbacf0b33d6b11d"

    livecheck do
      url :homepage
      regex(/mfiles[._-]helper[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-](\d+)\.dmg/i)
      strategy :page_match do |page, regex|
        match = page.match(regex)
        next if match.blank?

        "#{match[1]},#{match[2]}"
      end
    end
  end

  url "https://mfiles.maokebing.com/package/mfiles-helper-#{version.csv.first}-macos-#{version.csv.second}.dmg"
  name "MFiles"
  name "iTrunSo"
  name "爱传送"
  desc "Transfer files over local network"
  homepage "https://mfiles.maokebing.com/"

  depends_on :macos

  app "爱传送.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/爱传送.app"],
        must_succeed: false
  end

  uninstall quit: "com.windtune.itransfer"

  zap trash: "~/Library/Preferences/com.windtune.itransfer.plist"
end
