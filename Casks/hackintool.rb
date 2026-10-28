cask "hackintool" do
  version "5.0.5"
  sha256 :no_check # required as upstream package is updated in-place

  url "https://github.com/headkaze/Hackintool/releases/download/#{version}/Hackintool.zip"
  name "Hackintool"
  desc "Hackintosh patching tool"
  homepage "https://github.com/headkaze/Hackintool"

  auto_updates true
  depends_on macos: :monterey

  app "Hackintool.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Hackintool.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Caches/com.apple.helpd/Generated/com.Baker76.Hackintool.help*",
    "~/Library/Caches/com.apple.helpd/Generated/com.Headsoft.Hackintool.help*",
    "~/Library/Caches/com.Baker76.Hackintool",
    "~/Library/Caches/com.Headsoft.Hackintool",
    "~/Library/Cookies/com.Baker76.Hackintool.binarycookies",
    "~/Library/Cookies/com.Headsoft.Hackintool.binarycookies",
    "~/Library/Preferences/com.Baker76.Hackintool.plist",
    "~/Library/Preferences/com.Headsoft.Hackintool.plist",
  ]
end
