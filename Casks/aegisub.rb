cask "aegisub" do
  arch arm: "arm64", intel: "x64"

  version "3.5.0"
  sha256 arm:   "7d0701fbabcbcea1664b50e4f2726ea333721d1fbb313a3cc0c81e2a50b98cb5",
         intel: "3d4bf3b411b9d0c3cf59a18ab9f5d22039115d542eac459bf00c5e243b0d69e9"

  url "https://github.com/TypesettingTools/Aegisub/releases/download/v#{version}/Aegisub-#{version}-#{arch}.dmg"
  name "Aegisub"
  desc "Create and modify subtitles"
  homepage "https://github.com/TypesettingTools/Aegisub/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Aegisub.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Aegisub.app"],
        must_succeed: false
  end

  uninstall quit: "com.aegisub.aegisub"

  zap trash: [
    "~/Library/Application Support/Aegisub",
    "~/Library/Preferences/com.aegisub.aegisub.plist",
    "~/Library/Saved Application State/com.aegisub.aegisub.savedState",
  ]
end
