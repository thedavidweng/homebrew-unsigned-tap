cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.16.11-stable"
  sha256 arm:   "19eeaba695242f3a1863a66de3cc32a4f7c68884dcdad500ad61088be0dda3e8",
         intel: "1874099b612ab88ad19761e4fd7b019707f71a5426197bc033597362557b5ecf"

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
