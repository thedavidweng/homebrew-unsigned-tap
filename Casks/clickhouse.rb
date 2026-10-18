cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.21.9-stable"
  sha256 arm:   "1ab3cc236755d42bf196e66c567edcc5d471076a1efc70f0143853e6da3a02b6",
         intel: "290f52e5e349a9d46ad3105cbc40c76e1e76b8dd24099341614c8d915847e999"

  url "https://github.com/ClickHouse/ClickHouse/releases/download/v#{version}/clickhouse-macos#{arch}"
  name "Clickhouse"
  desc "Column-oriented database management system"
  homepage "https://clickhouse.com/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+[._-](lts|stable))$/i)
  end

  depends_on :macos

  binary "clickhouse-macos#{arch}", target: "clickhouse"

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end
end
