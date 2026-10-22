cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.25.15-stable"
  sha256 arm:   "fde0c17014075d84d3fdb153178b129b2a40e0e62a183e7f43fdd52e4805971d",
         intel: "15011b1058ef12e55f4e6c5743e9dec9eac6f21c455c026897eb27cb35bc2e9a"

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
