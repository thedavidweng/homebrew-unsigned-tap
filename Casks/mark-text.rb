cask "mark-text" do
  arch arm: "arm64", intel: "x64"

  version "0.21.2"
  sha256 arm:   "6c07b697ba3262e8b130ab3ee85bdc621077cf4035c8cc339098cdb2892142c1",
         intel: "597e09bd3d350e1535fb5df00e59e328fb618aac915e19db8e00ed6e4f2e800a"

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
