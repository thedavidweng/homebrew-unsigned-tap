cask "utc-menu-clock" do
  version "1.6"
  sha256 "8d8446c98cbee454b3960e4f598122719861fa463eb5265793a6a9b75fe56385"

  url "https://github.com/netik/UTCMenuClock/raw/master/downloads/UTCMenuClock_v#{version}_universal.zip"
  name "UTCMenuClock"
  desc "Menu bar clock"
  homepage "https://github.com/netik/UTCMenuClock"

  livecheck do
    url "https://github.com/netik/UTCMenuClock/tree/master/downloads"
    regex(/UTCMenuClock[._-]v?(\d+(?:\.\d+)+)[._-]universal\.zip/i)
    strategy :page_match
  end

  depends_on macos: :sequoia

  app "UTCMenuClock.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/UTCMenuClock.app"],
        must_succeed: false
  end

  uninstall launchctl: "application.UTCMenuClock.app.*"

  zap trash: "~/Library/Preferences/net.retina.UTCMenuClock.plist"
end
