cask "qtpass" do
  version "1.8.3"
  sha256 "384267b8dfb20b78ec3f82ce27c4ad144c36dec00622de6de09bfe34ad32dd46"

  url "https://github.com/IJHack/qtpass/releases/download/v#{version}/qtpass-#{version}.dmg"
  name "QtPass"
  desc "Multi-platform GUI for pass, the standard unix password manager"
  homepage "https://qtpass.org/"

  depends_on macos: :ventura

  app "QtPass.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/QtPass.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/org.ijhack.QtPass.plist",
    "~/Library/Saved Application State/org.qtpass.savedState",
  ]
end
