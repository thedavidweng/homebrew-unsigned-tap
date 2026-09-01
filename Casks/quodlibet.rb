cask "quodlibet" do
  version "4.4.0"
  sha256 "e06e1026e57699b6533fa0787da404c3dfdd3056eefcfcfce7a4a5be7f67b081"

  url "https://github.com/quodlibet/quodlibet/releases/download/release-#{version}/QuodLibet-#{version}.dmg"
  name "Quod Libet"
  desc "Music player and music library manager"
  homepage "https://quodlibet.readthedocs.io/"

  livecheck do
    url "https://quodlibet.github.io/appcast/osx-quodlibet.rss"
    strategy :sparkle
  end


  auto_updates true
  depends_on :macos

  app "QuodLibet.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.quodlibet",
    "~/Library/Preferences/io.github.quodlibet.quodlibet.plist",
    "~/Library/Saved Application State/io.github.quodlibet.quodlibet.savedState",
  ]
end
