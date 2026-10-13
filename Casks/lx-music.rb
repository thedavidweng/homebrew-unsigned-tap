cask "lx-music" do
  arch arm: "arm64", intel: "x64"

  version "2.12.6"
  sha256 arm:   "658c1fb0b503e94ceb8a610420164ae5274665f9b3573a4d4e3165d9a35ad14f",
         intel: "79b48917acb0f643bef37d4a6ca4f38a6e354e5123aea4645e62b94459edf46c"

  url "https://github.com/lyswhut/lx-music-desktop/releases/download/v#{version}/lx-music-desktop-#{version}-#{arch}.dmg"
  name "LX Music Assistant Desktop Edition"
  name "洛雪音乐助手桌面版"
  desc "Music app base on Electron & Vue"
  homepage "https://github.com/lyswhut/lx-music-desktop/"

  depends_on macos: :monterey

  app "lx-music-desktop.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/lx-music-desktop.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/lx-music-desktop",
    "~/Library/Logs/lx-music-desktop",
  ]
end
