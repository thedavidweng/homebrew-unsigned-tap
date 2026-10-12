cask "rocks-n-diamonds" do
  version "4.4.2.4"
  sha256 "03a334a6617f14dd2c980c3cb7e82779cd90dbbb8d08cce4850ed2f8d1ef67ef"

  url "https://www.artsoft.org/RELEASES/mac/rocksndiamonds/rocksndiamonds-#{version}-mac.dmg"
  name "Rocks'n'Diamonds"
  desc "Arcade-style game"
  homepage "https://www.artsoft.org/rocksndiamonds/"

  livecheck do
    url "https://github.com/ArtsoftEntertainment/rocksndiamonds.git"
    regex(/^(\d+(?:\.\d+){3})$/i)
    strategy :git
  end

  depends_on :macos

  app "Rocks'n'Diamonds.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Rocks'n'Diamonds.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Documents/Rocks'n'Diamonds",
    "~/Library/Saved Application State/org.artsoft.rocksndiamonds.savedState",
  ]
end
