cask "yggdrasil" do
  arch arm: "arm64", intel: "amd64"

  version "0.5.15"
  sha256 arm:   "5c0a21337cedfe9d63625306aaed2d3db730edbc74ffa4c621e8e7c9699a921c",
         intel: "4dc2baf5e8bd5c308ed636fbe065551ed4c5949673605831810e2af9957a7fe3"

  url "https://github.com/yggdrasil-network/yggdrasil-go/releases/download/v#{version}/yggdrasil-#{version}-macos-#{arch}.pkg"
  name "Yggdrasil"
  desc "End-to-end encrypted IPv6 networking to connect worlds"
  homepage "https://github.com/yggdrasil-network/yggdrasil-go"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  pkg "yggdrasil-#{version}-macos-#{arch}.pkg"

  uninstall launchctl: "yggdrasil",
            pkgutil:   "io.github.yggdrasil-network.pkg"

  zap delete: [
    "/etc/yggdrasil.conf",
    "/Library/Preferences/Yggdrasil",
  ]
end
