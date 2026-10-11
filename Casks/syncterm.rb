cask "syncterm" do
  version "1.9"
  sha256 "ca36ed9abeb41b2fccd91a100a2bf3e4965e184adff36259b04e1ca85b71b654"

  url "https://downloads.sourceforge.net/syncterm/syncterm/syncterm-#{version}/syncterm-#{version}-macos.zip"
  name "SyncTERM"
  desc "BBS terminal program"
  homepage "https://syncterm.bbsdev.net/"

  depends_on macos: :ventura

  app "SyncTERM.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/SyncTERM.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/SyncTERM",
    "~/Library/Preferences/syncterm.plist",
  ]
end
