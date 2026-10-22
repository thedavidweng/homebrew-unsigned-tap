cask "gisto" do
  arch arm: "aarch64", intel: "x64"

  version "2.15.5"
  sha256 arm:   "971326c3375b21a8c53dc0460c2b9aec6ae1e89fa2c6e4d587f8766ff7ad05f6",
         intel: "9cae43f49338f97b63586f21b033f0dd79b7e2553d7f63fe784b561b604b2271"

  url "https://github.com/Gisto/Gisto/releases/download/v#{version}/Gisto_#{version}_#{arch}.dmg"
  name "Gisto"
  desc "Snippets management desktop application"
  homepage "https://www.gisto.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Gisto.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Gisto.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Gisto",
    "~/Library/Caches/com.gistoapp.gisto2",
    "~/Library/Logs/Gisto",
    "~/Library/Preferences/com.gistoapp.gisto2.helper.plist",
    "~/Library/Preferences/com.gistoapp.gisto2.plist",
    "~/Library/Saved Application State/com.gistoapp.gisto2.savedState",
  ]
end
