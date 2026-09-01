cask "redeclipse" do
  version "2.0.0"
  sha256 "7eff1f196f9998d7bb7f26b4c79b596c2512b18a8b8ce16335634defbfcb072e"

  url "https://github.com/redeclipse/base/releases/download/v#{version}/redeclipse_#{version}_mac.tar.bz2"
  name "Red Eclipse"
  desc "Multiplayer & singleplayer first person shooter"
  homepage "https://www.redeclipse.net/"


  depends_on :macos

  app "redeclipse.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end
end
