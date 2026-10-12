cask "smplayer" do
  arch arm: "arm64", intel: "x86_64"

  version "26.8.29"
  sha256 arm:   "2fcbe6045c26d43ee25da58b539cc941430f05af499eef02df157c19d732659f",
         intel: "f2b0eae87cd5462135da680b7222161b8f409f8afa6512e507f6ca6ea5ddf65e"

  url "https://github.com/smplayer-dev/smplayer/releases/download/v#{version}/smplayer-#{version}-#{arch}-qt5.dmg"
  name "SMPlayer"
  desc "Media player with built-in codecs"
  homepage "https://www.smplayer.info/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "SMPlayer.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/SMPlayer.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/info.smplayer.SMPlayer.plist",
    "~/Library/Saved Application State/info.smplayer.SMPlayer.savedState",
  ]
end
