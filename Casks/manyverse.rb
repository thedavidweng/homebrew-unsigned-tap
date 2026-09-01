cask "manyverse" do
  version "0.2310.9-beta"
  sha256 "b5defc07fb08b6f8bf9c5eabdb0801b035b2b5eb95fb5de76efd3975f3b3c5b7"

  url "https://github.com/staltz/manyverse/releases/download/v#{version}/Manyverse-#{version}.dmg"
  name "Manyverse"
  desc "Social network built on the peer-to-peer SSB protocol"
  homepage "https://www.manyver.se/"

  livecheck do
    url :url
    regex(/v?(\d+(?:\.\d+)+-beta)/i)
    strategy :github_latest
  end


  depends_on :macos

  app "Manyverse.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/manyverse"

  caveats do
    requires_rosetta
  end
end
