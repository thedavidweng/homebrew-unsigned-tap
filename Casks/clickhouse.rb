cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.2.103-stable"
  sha256 arm:   "7f43a3c4d5f41e42ae6ec275c1531ca44b6018caae15217394fd85181ca1df59",
         intel: "8bdb041c299a849ebd9bbba72ffca925a24482abec690ae698be63818eece1ab"

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
