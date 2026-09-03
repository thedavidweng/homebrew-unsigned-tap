cask "weakauras-companion" do
  version "5.3.1"
  sha256 "bc430a4d29679c9e446dfe1c215596a307438cb66b885ce637b4c3b22b1fd990"

  url "https://github.com/WeakAuras/WeakAuras-Companion/releases/download/v#{version}/WeakAuras-Companion-#{version}-mac-universal.dmg"
  name "WeakAuras Companion"
  desc "Update your auras from Wago.io and creates regular backups of them"
  homepage "https://github.com/WeakAuras/WeakAuras-Companion/"

  depends_on macos: :monterey

  app "WeakAuras Companion.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/weakauras-companion",
    "~/Library/Logs/weakauras-companion",
    "~/Library/Preferences/wtf.weakauras.companion.plist",
  ]
end
