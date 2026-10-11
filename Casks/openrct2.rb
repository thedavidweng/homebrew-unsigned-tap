cask "openrct2" do
  # NOTE: "2" is not a version number, but an intrinsic part of the product name

  version "0.5.6"
  sha256 "5f57e48dbe438fd6fd5059954afe521a01365a36c11085b190067ea3204b6565"

  url "https://github.com/OpenRCT2/OpenRCT2/releases/download/v#{version}/OpenRCT2-v#{version}-macos-universal.zip"
  name "OpenRCT2"
  desc "Open-source re-implementation of RollerCoaster Tycoon 2"
  homepage "https://openrct2.io/"

  depends_on :macos

  app "OpenRCT2.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/OpenRCT2.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/CrashReporter/OpenRCT2*",
    "~/Library/Application Support/OpenRCT2",
    "~/Library/Preferences/io.openrct2.OpenRCT2.plist",
    "~/Library/Preferences/website.openrct2.OpenRCT2.plist",
    "~/Library/Saved Application State/io.openrct2.OpenRCT2.savedState",
  ]
end
