cask "ariang" do
  arch arm: "arm64", intel: "x64"

  version "1.3.15"
  sha256 arm:   "9466d3f424490e5f191536324a12ca78e93b5be0417037934b23a1b173f615f3",
         intel: "b54ce23cd50627e53e1abf2afbf6b0ca2010317e645a5ecabb0db8b4b43caeb6"

  url "https://github.com/mayswind/AriaNg-Native/releases/download/#{version}/AriaNg_Native-#{version}-macOS-#{arch}.dmg"
  name "AriaNg Native"
  desc "Better aria2 desktop frontend than AriaNg"
  homepage "https://github.com/mayswind/AriaNg-Native"

  depends_on :macos

  app "AriaNg Native.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/AriaNg Native.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/net.mayswind.ariang.plist",
    "~/Library/Saved Application State/net.mayswind.ariang.savedState",
  ]
end
