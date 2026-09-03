cask "nano-node" do
  version "28.2"
  sha256 "b57b17d8f21836b376edfd30420573067240d6ed5b4c5fce73a9772e50f535c5"

  url "https://github.com/nanocurrency/nano-node/releases/download/V#{version}/nano-node-V#{version}-Darwin.dmg"
  name "Nano"
  desc "Local node for the Nano cryptocurrency"
  homepage "https://nano.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Nano.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Preferences/net.raiblocks.rai_wallet.Nano.plist",
    "~/Library/RaiBlocks",
    "~/Library/Saved Application State/net.raiblocks.rai_wallet.savedState",
  ]
end
