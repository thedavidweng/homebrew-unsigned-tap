cask "mark-text" do
  arch arm: "arm64", intel: "x64"

  version "0.21.1"
  sha256 arm:   "329f608bbfc93d7bda33b6c570495d4d3aeffd33f5ed040ff764d1737189362c",
         intel: "40bc50d4bf24f1f3cfdf2b81c47eae6d3b97c9c28c65fab149eac3e1eb3a6650"

  url "https://github.com/marktext/marktext/releases/download/v#{version}/marktext-mac-#{arch}-#{version}.dmg"
  name "MarkText"
  desc "Markdown editor"
  homepage "https://github.com/marktext/marktext"

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
