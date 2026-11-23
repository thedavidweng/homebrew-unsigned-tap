cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.11.12-stable"
  sha256 arm:   "b0559d43662969c60386935a361f9e7036b774b1a32c30317174f515b39d1bcb",
         intel: "b4755bd33d115e59b1bf604b0fd589ecbf606511129aab880e7d0a09663ba73e"

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
