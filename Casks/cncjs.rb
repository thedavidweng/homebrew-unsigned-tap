cask "cncjs" do
  version "1.13.0"
  sha256 "aaca607e0c20170ce13d58e3e04cb09a19cd87d26032f4a34e59367001363fdd"

  url "https://github.com/cncjs/cncjs/releases/download/v#{version}/cncjs-app-#{version}-macos-arm64.dmg"
  name "CNSjs"
  desc "Interface for CNC milling controllers"
  homepage "https://cnc.js.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on :macos

  app "CNCjs.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/CNCjs.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.cncjs-sessions",
    "~/Library/Application Support/CNCjs",
    "~/Library/Preferences/org.cncjs.plist",
    "~/Library/Saved Application State/org.cncjs.savedState",
  ]
end
