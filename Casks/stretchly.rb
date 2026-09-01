cask "stretchly" do
  arch arm: "-arm64"

  version "1.21.0"
  sha256 arm:   "2360bc716dbe49bc95c2f11ce4c1cdd1ad50f6adc5af7896a9fead229a0d6bb3",
         intel: "ad2b0d4ccd9f71a3f614272792348475811554f9df5a45ff9814b58957b3449b"

  url "https://github.com/hovancik/stretchly/releases/download/v#{version}/stretchly-#{version}#{arch}.dmg"
  name "Stretchly"
  desc "Break time reminder app"
  homepage "https://hovancik.net/stretchly/"


  depends_on macos: :monterey

  app "Stretchly.app"

  uninstall quit: "net.hovancik.stretchly"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Stretchly",
    "~/Library/Logs/Stretchly",
    "~/Library/Preferences/net.hovancik.stretchly.plist",
  ]
end
