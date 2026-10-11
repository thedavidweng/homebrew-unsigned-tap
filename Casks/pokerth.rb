cask "pokerth" do
  version "2.1.10"
  sha256 "8a211d6b53d6e7e7cf5134e211c4473ed303e90a335da4e2a80e74f51c132acd"

  url "https://downloads.sourceforge.net/pokerth/PokerTH-#{version}-Combined.dmg"
  name "PokerTH"
  desc "Free Texas hold'em poker"
  homepage "https://www.pokerth.net/"

  livecheck do
    url "https://sourceforge.net/projects/pokerth/rss?path=/pokerth"
  end

  depends_on macos: :monterey

  app "PokerTH.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/PokerTH.app"],
        must_succeed: false
  end

  zap trash: "~/.pokerth"
end
