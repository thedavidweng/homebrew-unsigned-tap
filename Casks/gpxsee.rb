cask "gpxsee" do
  version "16.18"
  sha256 "17933c98579ca4be375a91c4c2057e5a7e3e62b745dde7d0cfb2e5140beea1aa"

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
