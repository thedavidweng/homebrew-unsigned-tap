cask "forkgram@legacy" do
  arch arm: "arm64", intel: "x86"

  version "7.1.3"
  sha256 arm:   "17426a3b813c37941f69c0d29c901237848acfe033d92846f06be968f97d00bb",
         intel: "2904089155278d8d370d6a7f186addec2ff535e9671a9340b06f37e8055dc859"

  url "https://github.com/Forkgram/tdesktop/releases/download/v#{version}/Forkgram.macOS.no.auto-update_#{arch}.zip"
  name "Forkgram (Legacy)"
  desc "Fork of Telegram Desktop"
  homepage "https://github.com/Forkgram/"

  livecheck do
    skip "Retained 7.1.3 package for macOS before Monterey; use forkgram for maintained releases"
  end

  conflicts_with cask: "forkgram"
  depends_on :macos

  app "Forkgram.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Forkgram.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Forkgram Desktop",
    "~/Library/Preferences/com.tdesktop.Telegram.plist",
  ]

  caveats <<~EOS
    This cask retains Forkgram 7.1.3 for macOS before Monterey.
    Use forkgram for maintained releases on macOS Monterey or later.
  EOS
end
