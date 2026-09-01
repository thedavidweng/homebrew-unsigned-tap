cask "pomotroid" do
  version "1.7.1"
  sha256 "2ccc0f4d64a8491f9771cb5a3c8df46b37ead752bd6592dcc9d562e4c139fd4a"

  url "https://github.com/Splode/pomotroid/releases/download/v#{version}/Pomotroid_#{version}_universal.dmg"
  name "Pomotroid"
  desc "Timer application"
  homepage "https://github.com/Splode/pomotroid"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end


  depends_on :macos

  app "Pomotroid.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/pomotroid",
    "~/Library/Preferences/com.splode.pomotroid.plist",
    "~/Library/Saved Application State/com.splode.pomotroid.savedState",
  ]
end
