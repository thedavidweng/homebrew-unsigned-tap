cask "v2rayu" do
  arch arm: "arm64", intel: "64"

  version "5.4.0"
  sha256 arm:   "73ca7829daa85dc2bac59020c97c7479a4a844dff4ce82c11664f7d641ef0c02",
         intel: "bf2e9a82d0560621edf5af8f727134728142e67a4d29a6bee60cfc91a04fd851"

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
