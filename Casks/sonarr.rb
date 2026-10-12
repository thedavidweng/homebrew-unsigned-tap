cask "sonarr" do
  arch arm: "arm64", intel: "x64"

  version "4.0.20.3014"
  sha256 arm:   "cee10454f117605faf8db2e8c6acb938c0cfa4907eb302cc159b7e8cafe564c0",
         intel: "51848a2eb25dadb77e2765c25eea9784335560215ec2d88b2c48c8ab872b351c"

  url "https://github.com/Sonarr/Sonarr/releases/download/v#{version}/Sonarr.main.#{version}.osx-#{arch}-app.zip"
  name "Sonarr"
  desc "PVR for Usenet and BitTorrent users"
  homepage "https://sonarr.tv/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  conflicts_with cask: "sonarr@beta"
  depends_on :macos

  app "Sonarr.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Sonarr.app"],
        must_succeed: false
  end

  zap trash: "~/.config/Sonarr"
end
