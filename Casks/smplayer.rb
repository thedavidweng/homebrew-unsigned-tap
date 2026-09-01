cask "smplayer" do
  version "25.6.0"
  sha256 "de88cc07f128f4e99cb36fa0dc5ae38dea261e4d8f51cd0235eca427cb23672e"

  url "https://github.com/smplayer-dev/smplayer/releases/download/v#{version}/smplayer-#{version}.dmg"
  name "SMPlayer"
  desc "Media player with built-in codecs"
  homepage "https://www.smplayer.info/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on :macos

  app "SMPlayer.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Preferences/info.smplayer.SMPlayer.plist",
    "~/Library/Saved Application State/info.smplayer.SMPlayer.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
