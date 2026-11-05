cask "rave" do
  version "1.18.30"
  sha256 "59f21f4ce2f1c726f48b22866a48c62aa7dde37dee9fe7464ad527d69c00b8de"

  url "https://static.rave-web.com/rave-desktop/mac/x64/Rave-#{version}.dmg"
  name "Rave"
  desc "Social streaming app"
  homepage "https://rave.io/"

  livecheck do
    url "https://static.rave-web.com/rave-desktop/mac/x64/latest-mac.yml"
    strategy :electron_builder
  end

  auto_updates true
  depends_on macos: :monterey

  app "Rave.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Rave.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Rave",
    "~/Library/Caches/io.rave.desktop",
    "~/Library/Caches/io.rave.desktop.ShipIt",
    "~/Library/Caches/rave-desktop-updater",
    "~/Library/HTTPStorages/io.rave.desktop",
    "~/Library/Logs/Rave",
    "~/Library/Preferences/io.rave.desktop.plist",
    "~/Library/Saved Application State/io.rave.desktop.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
