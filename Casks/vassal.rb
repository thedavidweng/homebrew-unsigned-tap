cask "vassal" do
  version "3.7.26"
  sha256 "e46f0957b820bc284bb79de5a325448dbf5c47e0fdebaa2aecff165f9cb7e3e0"

  url "https://github.com/vassalengine/vassal/releases/download/#{version}/VASSAL-#{version}-macos-universal.dmg"
  name "VASSAL"
  desc "Board game engine"
  homepage "https://www.vassalengine.org/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on :macos

  app "VASSAL.app"

  uninstall quit: "org.vassalengine.vassal"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/VASSAL"
end
