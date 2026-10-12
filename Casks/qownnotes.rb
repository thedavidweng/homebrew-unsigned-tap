cask "qownnotes" do
  version "26.10.5"
  sha256 "f4c8f393728163179ce534c42da60145a3470709aa8564fd2517970e9a5a1c1f"

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
