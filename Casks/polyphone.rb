cask "polyphone" do
  arch arm: "12", intel: "12_Intel"

  version "2.6.0"
  sha256 arm:   "6d182033d46f09803ca9217e6caf8f93154ca8443b7633e6050053e58f3a07e4",
         intel: "b01b762329be6904deb03316081c71eefbbc1ae42e0c8202f17a48d6a24ffabf"

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
