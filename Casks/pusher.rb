cask "pusher" do
  version "0.7.5"
  sha256 "b329a5106b6670bf50da4b91ba34d82102edb70074828cf4d0cd879b1a5e2180"

  url "https://github.com/noodlewerk/NWPusher/releases/download/#{version}/pusher.app.zip"
  name "NWPusher"
  desc "Send push notifications through Apple Push Notification Service"
  homepage "https://github.com/noodlewerk/NWPusher"


  depends_on :macos

  app "Pusher.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Pusher",
    "~/Library/Saved Application State/com.noodlewerk.Pusher.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
