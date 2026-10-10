cask "keepassxc@snapshot" do
  version "2.8.0,290601"
  sha256 "d8406491cee08dbed95404d83a617b2a86cf58c5e5d9006dd4b3109de3ca8344"

  url "https://snapshot.keepassxc.org/build-#{version.csv.second}/KeePassXC-#{version.csv.first}-snapshot.dmg"
  name "KeePassXC"
  desc "Password manager app"
  homepage "https://keepassxc.org/"

  livecheck do
    skip "Snapshot version and build sources changed; pinned snapshot download returns HTTP 404"
  end

  conflicts_with cask: [
    "keepassxc",
    "keepassxc@beta",
  ]
  depends_on macos: :sonoma

  app "KeePassXC.app"
  binary "#{appdir}/KeePassXC.app/Contents/MacOS/keepassxc-cli"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/KeePassXC.app"],
        must_succeed: false
  end

  uninstall quit: "org.keepassxc.keepassxc"

  zap trash: [
    "~/.keepassxc",
    "~/Library/Application Support/CrashReporter/KeePassXC_*.plist",
    "~/Library/Application Support/keepassxc",
    "~/Library/Caches/org.keepassx.keepassxc",
    "~/Library/Logs/DiagnosticReports/KeePassXC_*.crash",
    "~/Library/Preferences/keepassxc.keepassxc.plist",
    "~/Library/Preferences/org.keepassx.keepassxc.plist",
    "~/Library/Saved Application State/org.keepassx.keepassxc.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
