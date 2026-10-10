cask "appium-inspector" do
  arch arm: "arm64", intel: "x64"

  version "2026.9.2"
  sha256 arm:   "87ca4fcdec4c36165870e42748ecfe6cc32f4506f8a776875b00e8b1315edfa2",
         intel: "fbfe72111d9722101f20f14956e1624004022285bab07eac086ca9faaf0dfc4c"

  url "https://github.com/appium/appium-inspector/releases/download/v#{version}/Appium-Inspector-#{version}-mac-#{arch}.zip"
  name "Appium Inspector GUI"
  desc "GUI inspector for mobile apps"
  homepage "https://github.com/appium/appium-inspector/"

  # Not every GitHub release provides a file for macOS, so we check multiple
  # recent releases instead of only the "latest" release.
  livecheck do
    url :url
    regex(/^Appium.*?v?(\d+(?:\.\d+)+)[._-]mac[._-]#{arch}\.(?:dmg|pkg|zip)$/i)
    strategy :github_releases do |json, regex|
      json.map do |release|
        next if release["draft"] || release["prerelease"]

        release["assets"]&.map do |asset|
          match = asset["name"]&.match(regex)
          next if match.blank?

          match[1]
        end
      end.flatten
    end
  end

  depends_on macos: :ventura

  app "Appium Inspector.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Appium Inspector.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/appium-inspector",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/io.appium.inspector.sfl*",
    "~/Library/Logs/Appium Inspector",
    "~/Library/Preferences/io.appium.inspector.plist",
    "~/Library/Saved Application State/io.appium.inspector.savedState",
  ]
end
