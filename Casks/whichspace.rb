cask "whichspace" do
  version "1.4.5"
  sha256 "b1d67239198c33d8ceb9827ec0d2d2ec504baf1bea6f95b54e960ddfa489cfce"

  url "https://github.com/gechr/WhichSpace/releases/download/v#{version}/WhichSpace.zip"
  name "WhichSpace"
  desc "Active space menu bar icon"
  homepage "https://github.com/gechr/WhichSpace"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "WhichSpace.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/WhichSpace.app"],
        must_succeed: false
  end

  uninstall quit: "io.gechr.WhichSpace"

  zap trash: [
    "~/Library/Caches/io.gechr.WhichSpace",
    "~/Library/Cookies/io.gechr.WhichSpace.binarycookies",
    "~/Library/Preferences/io.gechr.WhichSpace.plist",
    "~/Library/Saved Application State/io.gechr.WhichSpace.savedState",
  ]
end
