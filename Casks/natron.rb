cask "natron" do
  version "2.5.0"
  sha256 "aa31fb6963344c281b53ca6e93823885e09f7d115ed5cc311abb833de4647537"

  url "https://github.com/NatronGitHub/Natron/releases/download/v#{version}/Natron-#{version}-macOS12-x86_64.dmg"
  name "Natron"
  desc "Open-source node-graph based video compositing software"
  homepage "https://NatronGitHub.github.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "Natron.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.Natron",
    "~/Library/Application Support/INRIA/Natron",
    "~/Library/Caches/INRIA/Natron",
    "~/Library/Preferences/com.inria.Natron.plist",
  ]

  caveats do
    requires_rosetta
  end
end
