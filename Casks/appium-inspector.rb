cask "appium-inspector" do
  arch arm: "arm64", intel: "x64"

  version "2026.11.5"
  sha256 arm:   "6b8783e8f080d17e0417f807b9e0bc3575b0c7483f8f69b7269979db4128689c",
         intel: "3a7e1602950ac5390c223bab771eb0d004f47c94772e39b2d56fd6b60b0c9c60"

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
