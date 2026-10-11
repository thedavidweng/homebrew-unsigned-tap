cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.15.5-stable"
  sha256 arm:   "355dc3d2aae2f61b3f90cb983e0aaa8a583b72b20c5cef2e6b28a85e39951f90",
         intel: "14e727a279d467289ece63edb9b6902ba42751b9718afb4bb726322d94302bd0"

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
