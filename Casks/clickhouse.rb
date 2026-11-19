cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.7.24-stable"
  sha256 arm:   "d604f31889c0d182d3b14e23aab50908d1985f34c0409519e9929c31a46ec702",
         intel: "5499e32837f2c149c27e95c401c5f3645d28570694b00deb9bc5a1801b09e0a3"

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
