cask "yesplaymusic" do
  arch arm: "arm64", intel: "x64"

  version "0.4.11"
  sha256 arm:   "8605bf452379962b7d36d23e5eeb79b298521f457de32df0f6ed9f75681c24b3",
         intel: "bc65dd0efd30d92bc62e54192372997e0e7840fbef6c8920c3cd97f6deed0ab7"

  url "https://github.com/qier222/YesPlayMusic/releases/download/v#{version}/YesPlayMusic-mac-#{version.hyphens_to_dots.major_minor_patch}-#{arch}.dmg"
  name "YesPlayMusic"
  desc "Third-party NetEase cloud player"
  homepage "https://github.com/qier222/YesPlayMusic"

  livecheck do
    url :url
    regex(%r{/v?(\d+(?:[.-]\d+)+)/YesPlayMusic(?:[._-]mac)?[._-]v?\d+(?:[.-]\d+)+[._-]#{arch}\.dmg}i)
    strategy :github_releases do |json, regex|
      json.map do |release|
        next if release["draft"] || release["prerelease"]

        release["assets"]&.map do |asset|
          match = asset["browser_download_url"]&.match(regex)
          next if match.blank?

          match[1]
        end
      end.flatten
    end
  end

  depends_on :macos

  app "YesPlayMusic.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/YesPlayMusic.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/YesPlayMusic",
    "~/Library/Preferences/com.electron.yesplaymusic.plist",
    "~/Library/Saved Application State/com.electron.yesplaymusic.savedState",
  ]
end
