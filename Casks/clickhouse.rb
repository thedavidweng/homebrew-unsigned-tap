cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.11.2.4-stable"
  sha256 arm:   "b26048f1ea10bb1103a2d49428d3a79ca8c59d204bb3196285016ec51c38452b",
         intel: "0a6497cee5705decd4fb86b5c801fa37bfc5f95f55ced9e5ec620443fdb08795"

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
