cask "v2rayu" do
  arch arm: "arm64", intel: "64"

  version "5.4.1"
  sha256 arm:   "efe035f6f585140ca75c89debe07d5802d08e4495a0664a4b9eb0b1990f82001",
         intel: "44134a088b01e2ecb5eec9dcbb26e70883dd30a6b5d7a98842d06493378759b2"

  url "https://github.com/yanue/V2rayU/releases/download/v#{version}/V2rayU-#{arch}.dmg"
  name "V2rayU"
  desc "Collection of tools to build a dedicated basic communication network"
  homepage "https://github.com/yanue/V2rayU"

  # A tag using the stable version format is sometimes marked as "Pre-release"
  # on the GitHub releases page, so we have to use the `GithubLatest` strategy.
  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "V2rayU.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/V2rayU.app"],
        must_succeed: false
  end

  uninstall launchctl: [
    "yanue.v2rayu.http",
    "yanue.v2rayu.v2ray-core",
  ]

  zap trash: [
    "~/.V2rayU",
    "~/Library/Application Support/net.yanue.V2rayU",
    "~/Library/Caches/net.yanue.V2rayU",
    "~/Library/Containers/net.yanue.V2rayU.Launcher",
    "~/Library/HTTPStorages/net.yanue.V2rayU",
    "~/Library/LaunchAgents/yanue.v2rayu.v2ray-core.plist",
    "~/Library/Logs/V2rayU.log",
    "~/Library/Preferences/net.yanue.V2rayU.plist",
  ]
end
