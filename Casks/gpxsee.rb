cask "gpxsee" do
  version "16.20"
  sha256 "237ff05ccc395bfeda185f86853adb25a242310ed4a48ae142b74d5e1c946790"

  url "https://downloads.sourceforge.net/gpxsee/Mac%20OS%20X/GPXSee-#{version}.dmg"
  name "GPXSee"
  desc "GPS log file viewer and analyzer"
  homepage "https://www.gpxsee.org/"

  livecheck do
    url "https://sourceforge.net/projects/gpxsee/rss?path=/Mac%20OS%20X"
    regex(%r{url=.*?/GPXSee[._-]v?(\d+(?:\.\d+)+)\.dmg}i)
  end

  depends_on macos: :sonoma

  app "GPXSee.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/GPXSee.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Caches/GPXSee",
    "~/Library/Preferences/com.gpxsee.GPXSee.plist",
  ]
end
