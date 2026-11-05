cask "qownnotes" do
  version "26.11.5"
  sha256 "28c9d1df40964de8929259c8513a32f341d3ba8bdb18c632c0bd32918dc884c0"

  url "https://github.com/pbek/QOwnNotes/releases/download/v#{version}/QOwnNotes.dmg"
  name "QOwnNotes"
  desc "Plain-text file notepad and todo-list manager"
  homepage "https://www.qownnotes.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "QOwnNotes.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/QOwnNotes.app"],
        must_succeed: false
  end

  uninstall quit: "com.PBE.QOwnNotes"

  zap trash: [
    "~/Library/Preferences/com.pbe.QOwnNotes.plist",
    "~/Library/Saved Application State/com.PBE.QOwnNotes.savedState",
  ]
end
