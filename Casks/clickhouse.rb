cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.4.207-stable"
  sha256 arm:   "2560c762a0b5458f0d159934b44acc6f383b9f4f01d6a76497fb9f0e5369bc26",
         intel: "afc915a5ffd19f425acb6ba159143f3b1dc09a811c2781bc72c1f032ac283952"

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
