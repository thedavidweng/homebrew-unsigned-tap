cask "groestlcoin-core" do
  arch arm: "arm64", intel: "x86_64"

  version "32.1"
  sha256 arm:   "de54a1b511a2b43cf9ae86322c3485a63ec8f9aa3b7e4d697b3cf848e8ee6a4f",
         intel: "a347e9f14cdd62bc27641ea08bb62802fc7637a4b553123ca78b41f6f7fa4f60"

  url "https://github.com/groestlcoin/groestlcoin/releases/download/v#{version}/groestlcoin-#{version}-#{arch}-apple-darwin-unsigned.zip"
  name "Groestlcoin Core"
  desc "Groestlcoin client and wallet"
  homepage "https://www.groestlcoin.org/groestlcoin-core-wallet/"

  depends_on macos: :sonoma

  # Renamed for consistency: app name is different in the Finder and in a shell.
  app "Groestlcoin-Qt.app", target: "Groestlcoin Core.app"

  preflight_steps do
    set_permissions "Groestlcoin-Qt.app", "0755"
  end

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Groestlcoin Core.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Preferences/org.groestlcoin.Groestlcoin-Qt.plist"
end
