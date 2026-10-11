cask "macstroke" do
  version "3.1.0"
  sha256 "8f300f5679237ff754ae585f391ba05ab39e628bfaa5136b245d6efe8dc7e53d"

  url "https://github.com/mtjo/MacStroke/releases/download/#{version}/MacStroke.zip"
  name "MacStroke"
  desc "Configurable global mouse gestures"
  homepage "https://github.com/mtjo/MacStroke/"

  depends_on macos: :ventura

  app "MacStroke.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/MacStroke.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Scripts/net.mtjo.MacStroke.FinderSyncExtension",
    "~/Library/Caches/MacStroke",
    "~/Library/Caches/net.mtjo.MacStroke",
    "~/Library/Containers/net.mtjo.MacStroke.FinderSyncExtension",
    "~/Library/Cookies/net.mtjo.MacStroke.binarycookies",
    "~/Library/Preferences/net.mtjo.MacStroke.plist",
  ]
end
