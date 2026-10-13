cask "jgrennison-openttd" do
  version "0.73.4"
  sha256 "3201532f5c3c9c0830cc5c0f088f334f25345b765d7930e2688886c9dda6ad6d"

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
