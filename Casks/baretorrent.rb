cask "baretorrent" do
  version "0.4.4"
  sha256 "dea7c210e9b57b74fc44b498d8f5d238458ffffff3c66b2a91bd77f5cec5238d"

  url "https://launchpad.net/baretorrent/trunk/#{version}/+download/baretorrent-#{version}-osx-x64.dmg"
  name "baretorrent"
  desc "Bittorrent client"
  homepage "https://launchpad.net/baretorrent"

  livecheck do
    url :url
    regex(/href=.*?baretorrent[._-]v?(\d+(?:\.\d+)+)(?:[._-][^"' >]+?)?\.dmg/i)
  end

  depends_on :macos

  app "baretorrent.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/baretorrent",
    "~/Library/Saved Application State/baretorrent.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
