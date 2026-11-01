cask "pokerth" do
  version "2.1.11"
  sha256 "d354cf593af6c624a70c63f9dc07ff44b45eb09f60a7c8a89a565c1372c363b2"

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
