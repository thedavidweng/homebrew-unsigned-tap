cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.10.9.12-stable"
  sha256 arm:   "2e395b3f758ea1b3a00126451f5b1ffd78e956c52c89d8209f43b2da009d1a37",
         intel: "03d48e4cacc165bf379ef0212bebc19b8f7550a088cd3a70cffed2a8d7891be1"

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
