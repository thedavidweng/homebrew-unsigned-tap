cask "gisto" do
  arch arm: "aarch64", intel: "x64"

  version "2.16.0"
  sha256 arm:   "3bdba1a95636f4a939b66247750737412551dbfa520ff172f8676540787aab00",
         intel: "7aff939ce1c37248e4e70f7c62cb3da06ee943a0551c6925a5a5a90259d9fb59"

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
