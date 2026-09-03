cask "qxmledit" do
  version "0.9.18"
  sha256 "9f189fbd0cf72ec7c94fad3d3f3850dc7d898cff5a088353cfd54877cf9f2bb9"

  url "https://downloads.sourceforge.net/qxmledit/QXmlEdit-#{version}.dmg"
  name "QXmlEdit"
  desc "XML editor"
  homepage "https://qxmledit.org/"

  livecheck do
    url :url
    regex(%r{url=.*?/QXmlEdit[._-]v?(\d+(?:\.\d+)+)\.dmg}i)
  end

  depends_on :macos

  app "QXmlEdit.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/QXmlEdit",
    "~/Library/Preferences/org.qxmledit.QXmlEdit.plist",
    "~/Library/Saved Application State/org.qxmledit.QXmlEdit.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
