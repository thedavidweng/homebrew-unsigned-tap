cask "jgrennison-openttd" do
  version "0.73.3"
  sha256 "e01ea97da078efb8786104e931df17e8de010de4f68b589561cb900b3cbdee9f"

  url "https://github.com/JGRennison/OpenTTD-patches/releases/download/jgrpp-#{version}/openttd-jgrpp-#{version}-macos-universal.dmg"
  name "JGR's OpenTTD Patchpack"
  desc "Collection of patches applied to OpenTTD"
  homepage "https://github.com/JGRennison/OpenTTD-patches/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "OpenTTD.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/OpenTTD.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Documents/OpenTTD",
    "~/Library/Application Support/CrashReporter/openttd_*.plist",
    "~/Library/Logs/DiagnosticReports/openttd_*.crash",
    "~/Library/Saved Application State/org.openttd.openttd.jgrpp.savedState",
    "~/Library/Saved Application State/org.openttd.openttd.savedState",
  ]
end
