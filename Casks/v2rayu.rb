cask "v2rayu" do
  arch arm: "arm64", intel: "64"

  version "5.3.0"
  sha256 arm:   "e5097162a0037e1db55aa4a93d2999b83ab9aebbd4ca850bb090baa2e82064fd",
         intel: "951bdc7c6bf9446cfc675fdb1aef22f703b69240fb1ee4282dbbe56f7bcd5243"

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
