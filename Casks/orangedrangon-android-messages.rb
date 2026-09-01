cask "orangedrangon-android-messages" do
  version "6.0.3"
  sha256 "9d3f75a6de9948d2cb4274f87b443d69d081935b9341cc0ab2b308b534d3a936"

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
