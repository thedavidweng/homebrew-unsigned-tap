cask "gswitch" do
  version "1.9.7"
  sha256 "5d212c1bd39f6bfae588797fa09b959051dc4eefd26ec05fbd26b798125b976a"

  url "https://github.com/CodySchrank/gSwitch/releases/download/#{version}/gSwitch.zip"
  name "gSwitch"
  desc "Set which graphics card to use"
  homepage "https://codyschrank.github.io/gSwitch/"

  depends_on :macos

  app "gSwitch.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Caches/gSwitch",
    "~/Library/Preferences/com.CodySchrank.gSwitch.plist",
  ]

  caveats do
    requires_rosetta
  end
end
