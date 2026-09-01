cask "pokerth" do
  version "2.0.8"
  sha256 "c35ba20313883caac2cce5be6910b3c05f3db5f284f509ff12340d7fc0da07c3"

  url "https://downloads.sourceforge.net/pokerth/PokerTH-Widget-#{version}.dmg"
  name "PokerTH"
  desc "Free Texas hold'em poker"
  homepage "https://www.pokerth.net/"


  depends_on macos: :monterey

  app "PokerTH.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.pokerth"

  caveats do
    requires_rosetta
  end
end
