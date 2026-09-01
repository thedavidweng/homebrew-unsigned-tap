cask "double-commander" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.1.32"
  sha256 arm:   "dfbf339a2ef78e2346ad2a874a9961f5b725c2a8d8b32c33bc7751348488792b",
         intel: "f2b39a06bcd4da63768db3f21cc36395223b9b289671479439adb6f66c594c15"

  url "https://github.com/doublecmd/doublecmd/releases/download/v#{version}/doublecmd-#{version}.cocoa.#{arch}.dmg"
  name "Double Commander"
  desc "File manager with two panels"
  homepage "https://doublecmd.sourceforge.io/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on macos: :big_sur

  app "Double Commander.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Caches/doublecmd"
end
