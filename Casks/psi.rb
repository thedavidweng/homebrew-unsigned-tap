cask "psi" do
  version "1.4"
  sha256 "e6955acc3d9c7b835b29e1b13918abde6a4bf4748524847885cf896bc0972c8a"

  url "https://downloads.sourceforge.net/psi/psi-#{version}-mac.dmg"
  name "Psi"
  desc "Instant messaging application designed for the XMPP network"
  homepage "https://psi-im.org/"

  livecheck do
    url "https://psi-im.org/downloads/"
    regex(/psi[._-]?(\d+(?:\.\d+)*)[._-]?mac\.dmg/i)
  end


  depends_on :macos

  app "Psi.app"

  uninstall quit: "org.psi-im"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Psi",
    "~/Library/Caches/Psi",
    "~/Library/Saved Application State/org.psi-im.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
