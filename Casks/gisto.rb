cask "gisto" do
  arch arm: "aarch64", intel: "x64"

  version "2.17.0"
  sha256 arm:   "4de7947ff33328072cfde8398feb813ed78c875eead8b9585fe9a3670c6b91da",
         intel: "af0db1a2fd8480273c11af9b85966599982085dad8a81f92729aa5555877b8b7"

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
