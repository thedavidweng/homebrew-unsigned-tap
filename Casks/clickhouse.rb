cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.6.18-stable"
  sha256 arm:   "46112152a571329990c9dc9e0328c46d6e17efc8bc5daa02d8ce492851be4ce3",
         intel: "4d3c7017edae94ac1cdcca5ba266f01401af98b3c09b04f4433325eda8beae5b"

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
