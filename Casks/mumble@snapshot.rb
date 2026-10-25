cask "mumble@snapshot" do
  version "1.6.1001"
  sha256 "9572259ec3a9078d5938693c17cce11b80a8b3c5c1e424115a620a978958593f"

  url "https://dl.mumble.info/snapshot/mumble_client-#{version}.x64.dmg"
  name "Mumble Snapshot"
  desc "Open-source, low-latency, high quality voice chat software for gaming"
  homepage "https://mumble.info/"

  livecheck do
    url "https://dl.mumble.info/latest/snapshot/client-macos-x64"
    strategy :header_match
  end

  conflicts_with cask: "mumble"
  depends_on :macos

  app "Mumble.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Mumble.app"],
        must_succeed: false
  end

  zap trash: [
    "/Library/ScriptingAdditions/MumbleOverlay.osax",
    "~/Library/Application Support/Mumble",
    "~/Library/Logs/Mumble.log",
    "~/Library/Preferences/net.sourceforge.mumble.Mumble.plist",
    "~/Library/Saved Application State/net.sourceforge.mumble.Mumble.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
