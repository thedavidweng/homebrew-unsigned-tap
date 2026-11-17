cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.5.57-stable"
  sha256 arm:   "ccbad446e1ab4e5177cf39377b974c365b54e32d1b883837622e2f3fbe66fa89",
         intel: "a78dad3b9e6c3be03a9093d55ed2b15311f9e289d06349dd72e2e58ac8aeac52"

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
