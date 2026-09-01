cask "vassal" do
  version "3.7.24"
  sha256 "b94d98bffc55da9338ace9bbf213080ce03158a5b8de9b5d2fe925f6437d9a9b"

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

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/VASSAL"
end
