cask "bluefish" do
  version "2.4.2"
  sha256 "c10c1d90a61319553f85febde2955d9684de23a2e5ab39210df773b9f46855b5"

  url "https://www.bennewitz.com/bluefish/stable/binaries/macosx/Bluefish-#{version}.dmg"
  name "Bluefish"
  desc "Open source code editor"
  homepage "https://bluefish.openoffice.nl/index.html"

  livecheck do
    url "https://www.bennewitz.com/bluefish/stable/binaries/macosx/"
    regex(/href=.*?Bluefish[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
  end

  depends_on :macos

  app "Bluefish.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.bluefish",
    "~/Library/Preferences/nl.openoffice.bluefish.plist",
    "~/Library/Saved Application State/nl.openoffice.bluefish.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
