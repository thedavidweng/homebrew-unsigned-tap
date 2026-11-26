cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.11.3.10-stable"
  sha256 arm:   "d28594d68685e0383c796c866048ce86bf346a4aa8657a450b8d6a83ca7f3a2b",
         intel: "74b4dea9a97c707c9b5259d4f28bbe224aa16175000d3bafc1744ae0dd4777c1"

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

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
