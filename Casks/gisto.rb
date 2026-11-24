cask "gisto" do
  arch arm: "aarch64", intel: "x64"

  version "2.18.0"
  sha256 arm:   "e73faa81b295ea14b901d1a0e678df203b2f54e7fcf9e63fca9a8ac95b3c76ee",
         intel: "4c463d36c7d086243be6ed00e07a4c6f7b5adfc73d2767318c724c48c978c3aa"

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
