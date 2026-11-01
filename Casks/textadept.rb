cask "textadept" do
  version "13.1"
  sha256 "15bcfa211f8692e1048340503a2b13cbab3891f88b72f17f6774cd89cd97c0da"

  url "https://github.com/orbitalquark/textadept/releases/download/textadept_#{version}/textadept_#{version}.macOS.zip"
  name "Textadept"
  desc "Text editor"
  homepage "https://orbitalquark.github.io/textadept/"

  livecheck do
    url :url
    regex(/^textadept[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on :macos

  app "Textadept.app"
  binary "ta"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Textadept.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.textadept",
    "~/Library/Saved Application State/com.textadept.savedState",
  ]
end
