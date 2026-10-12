cask "iina+" do
  version "0.8.34"
  sha256 "2e108f92c7ecf10f0c773bec0f8b76b4bb0dca65b7b024c556a4146d0b650f70"

  url "https://github.com/xjbeta/iina-plus/releases/download/#{version}/IINA+.#{version}.zip"
  name "IINA+"
  desc "Extra danmaku support for iina (iina 弹幕支持)"
  homepage "https://github.com/xjbeta/iina-plus"

  auto_updates true
  depends_on macos: :ventura

  app "IINA+.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/IINA+.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.xjbeta.iina-plus",
    "~/Library/Caches/com.xjbeta.iina-plus",
    "~/Library/Preferences/com.xjbeta.iina-plus.plist",
    "~/Library/WebKit/com.xjbeta.iina-plus",
  ]

  caveats do
    "This IINA+ binary requires macOS 13.5 or later."
  end
end
