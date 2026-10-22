cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.9.24.8-stable"
  sha256 arm:   "cd2ecb22c5ae0b3c9de11a82fd950c608b037611b0cfe91821f728c238c90ade",
         intel: "fd8beee0fb7f900daef48876d2c92279b6f34be1b8cde9c50cb85b135a922eaa"

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
