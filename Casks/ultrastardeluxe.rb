cask "ultrastardeluxe" do
  arch arm: "ARM", intel: "x86"

  version "2026.9.0"
  sha256 arm:   "d7d9ffbf51790067084f564fc6306eda954594710044a26395844753fd4e4e57",
         intel: "a73c6dba46aa4d24635f25ebbe1408af62596faf369e0eef3cc70a066c9fba34"

  url "https://github.com/UltraStar-Deluxe/USDX/releases/download/v#{version}/UltraStarDeluxe-mac-#{arch}-#{version}.dmg"
  name "UltraStar Deluxe"
  desc "Karaoke game"
  homepage "https://usdx.eu/"

  depends_on :macos

  app "UltraStarDeluxe.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/UltraStarDeluxe.app"],
        must_succeed: false
  end

  uninstall quit: "org.ultrastardeluxe.ultrastardeluxe"

  zap trash: "~/Library/Application Support/UltraStarDeluxe1.3"
end
