cask "electronmail" do
  arch arm: "arm64", intel: "x64"

  version "5.3.10"
  sha256 arm:   "7863a938167fe82481685157c43d2d61d8563c24f047d9fefecb6c107eef4765",
         intel: "f318f9db3c6d234ee9f8f66fb74fa7b975ea78eeb8048bbcfb7320dc2de4ea6c"

  url "https://github.com/vladimiry/ElectronMail/releases/download/v#{version}/electron-mail-#{version}-mac-#{arch}.dmg"
  name "ElectronMail"
  desc "Unofficial ProtonMail Desktop App"
  homepage "https://github.com/vladimiry/ElectronMail"

  depends_on macos: :ventura

  app "electron-mail.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/electron-mail.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/github.comvladimiryelectronmail.sfl*",
    "~/Library/Application Support/electron-mail",
    "~/Library/Logs/ElectronMail",
    "~/Library/Preferences/github.comvladimiryElectronMail.plist",
    "~/Library/Saved Application State/github.comvladimiryElectronMail.savedState",
  ]
end
