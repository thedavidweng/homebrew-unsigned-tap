cask "orangedrangon-android-messages" do
  version "6.1.0"
  sha256 "379297706fdfb1a1d332970ffe6161fd94f73b9ee230e1f04bb3a18332daf847"

  url "https://github.com/OrangeDrangon/android-messages-desktop/releases/download/v#{version}/Android-Messages-v#{version}-mac-universal.zip"
  name "Android Messages Desktop"
  desc "Desktop client for Android Messages"
  homepage "https://github.com/OrangeDrangon/android-messages-desktop"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on macos: :monterey

  app "Android Messages.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/android-messages-desktop"
end
