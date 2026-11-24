cask "polyphone" do
  arch arm: "12", intel: "12_Intel"

  version "2.7.3"
  sha256 arm:   "a9c6bc32fc4bac4c878bc6bf71eb4a92112e67bce3c36b95dfba4fbbc520f47e",
         intel: "a186d11bae0438d2c425ec3d90a8d17dfcc170265ba8adbde8e944d3c0bd7d00"

  url "https://github.com/davy7125/polyphone/releases/download/#{version}/Polyphone_#{version}-macOS_#{arch}.dmg"
  name "Polyphone"
  desc "Soundfont editor for quickly designing musical instruments"
  homepage "https://www.polyphone.io/en"

  livecheck do
    url :url
    regex(/^Polyphone[._-]v?(\d+(?:\.\d+)+)[._-]macOS[._-]#{arch}\.dmg$/i)
    strategy :github_releases do |releases, regex|
      releases.reject { |release| release["draft"] || release["prerelease"] }.flat_map do |release|
        release["assets"].filter_map { |asset| asset["name"][regex, 1] }
      end
    end
  end

  depends_on macos: :monterey

  app "Polyphone.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Polyphone.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.polyphone.Polyphone.plist",
    "~/Library/Saved Application State/fr.polyphone.Polyphone.savedState",
  ]
end
