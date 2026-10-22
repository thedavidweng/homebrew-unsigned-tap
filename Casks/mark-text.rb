cask "mark-text" do
  arch arm: "arm64", intel: "x64"

  version "0.23.0"
  sha256 arm:   "d7e9ef4fc7c7f353003fc3f34d3a56514a8b05e19298a74ed6ce13c26fe2679f",
         intel: "2f78980ea1c2fb7deea56a1fd61e97031457443be52631c09a1611cff5f71108"

  url "https://github.com/marktext/marktext/releases/download/v#{version}/marktext-mac-#{arch}-#{version}.dmg"
  name "MarkText"
  desc "Markdown editor"
  homepage "https://github.com/marktext/marktext"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :monterey

  app "MarkText.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/MarkText.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/marktext",
    "~/Library/Logs/marktext",
    "~/Library/Preferences/com.github.marktext.marktext.plist",
    "~/Library/Saved Application State/com.github.marktext.marktext.savedState",
  ]
end
