cask "scidvsmac" do
  version "4.27"
  sha256 "3a6ba7b47bdc35a83df9b534cb989c33c0d1d79180b1fbc91cbd7f9059f983a0"

  url "https://downloads.sourceforge.net/scidvspc/ScidvsMac-#{version}.x64.dmg"
  name "Scid vs. Mac"
  desc "Chess toolkit"
  homepage "https://scidvspc.sourceforge.net/"

  livecheck do
    url :homepage
    regex(/ScidvsMac-(\d+(?:\.\d+)*)\.x64\.dmg/i)
  end

  depends_on :macos

  app "ScidvsMac.app"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: [
    "~/.scidvspc",
    "~/Library/Preferences/net.sf.scid.plist",
    "~/Library/Saved Application State/net.sf.scid.savedState",
  ]
end
