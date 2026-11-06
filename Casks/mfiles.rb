cask "mfiles" do
  version "2.6.1,2026110601"
  sha256 "5d1b101638c3a8a7fd27e64b7b05f2785fc1af64de5cd2fc8fbacf0b33d6b11d"

  url "https://mfiles.maokebing.com/package/mfiles-helper-#{version.csv.first}-macos-#{version.csv.second}.dmg"
  name "MFiles"
  name "iTrunSo"
  name "爱传送"
  desc "Transfer files over local network"
  homepage "https://mfiles.maokebing.com/"

  livecheck do
    url :homepage
    regex(/mfiles[._-]helper[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-](\d+)\.dmg/i)
    strategy :page_match do |page, regex|
      match = page.match(regex)
      next if match.blank?

      "#{match[1]},#{match[2]}"
    end
  end

  depends_on macos: :monterey

  app "爱传送.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/爱传送.app"],
        must_succeed: false
  end

  uninstall quit: "com.windtune.itransfer"

  zap trash: "~/Library/Preferences/com.windtune.itransfer.plist"
end
