cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.20.23-stable"
  sha256 arm:   "38e36bbd7f3e55229930f0fcc5b71ac635c74afd81a146d99d0269d3c1024cb6",
         intel: "bc00e99ff1ed6e907b450f0fd8358936b2fb97d08faf00d3ba542f2378599cc2"

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
