cask "clickhouse" do
  arch arm: "-aarch64"

  version "26.11.1.2942-stable"
  sha256 arm:   "977f4080ecbfbe8b2fdd8e1f7a632ce10f0caea18262a5ec5b95af2a7efdbf00",
         intel: "bcec0571a7afb5274b77aded1d1a715bc5d99cd09c5c79afb710544d7468a1a6"

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
