cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.17.8-stable"
  sha256 arm:   "ee2545a19381433b16ec0ec3aa17835ed224e5168a66d333b11798a40e635bfb",
         intel: "75aa28ca112732a969c606685d8b4a3075af9407504c89469371b5e5fc9e59df"

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
