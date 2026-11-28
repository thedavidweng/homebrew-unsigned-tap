cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.11.4.11-stable"
  sha256 arm:   "e99e96b993e82ba9fb7fddd523ec4304db12836e7d2593fd77327ef8e472ce8f",
         intel: "e57d7afb12e6073b4d90b0b1774ecef6a7f2f78be2e4efe84acc3ee872740d11"

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
