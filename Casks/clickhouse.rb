cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.10.3-stable"
  sha256 arm:   "f670476cbaf8bfae976212cd428d7856eacdaf2dd616e1072e584fd02ebb52b7",
         intel: "77288bb27d4792e0ce11e3e7d25fddfa811f784d8eddc33fd11a3b04134449fb"

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
