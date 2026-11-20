cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.8.34-stable"
  sha256 arm:   "5a430750ae5f737e5f438480b052c4cec9ada4eae6bfb82d2820648a74234f43",
         intel: "3ce5a202b9c3aff4052c1a9443fcd3f5a6e8b5b070900bf10a1c695e72a859e0"

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
