cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.12.13-stable"
  sha256 arm:   "f03b1e5cf5523d990bb3830f86c72bd3271f3a2eb953b58dc79f6bfecd59377b",
         intel: "3693ed248a80fadb2b7b7e7f03b5ebbf89cc02f962fd1b4a22b8803784d2e6fb"

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
