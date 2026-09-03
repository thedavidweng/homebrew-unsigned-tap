cask "cctalk" do
  version "7.10.19-1407"
  sha256 :no_check

  url "https://www.cctalk.com/webapi/basic/v1.1/version/down?apptype=1&terminalType=8&versionType=103"
  name "CCtalk"
  desc "Real-time interactive education platform"
  homepage "https://www.cctalk.com/download/"

  livecheck do
    url :url
    regex(/CCtalk[._-]v?(\d+(?:[.-]\d+)+)\.dmg/i)
    strategy :header_match
  end

  depends_on :macos

  app "CCtalk.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/CCtalk",
    "~/Library/Application Support/com.hujiang.mac.cctalk",
    "~/Library/Caches/com.crashlytics.data/com.hujiang.mac.cctalk",
    "~/Library/HTTPStorages/com.hujiang.mac.cctalk",
    "~/Library/Preferences/com.hujiang.mac.cctalk.plist",
  ]

  caveats do
    requires_rosetta
  end
end
