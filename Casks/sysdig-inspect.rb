cask "sysdig-inspect" do
  version "0.12.1"
  sha256 "73287e0b24ca25531d9592f51fa50325f5140a667eb7585066401cbe2dd7ac0d"

  url "https://github.com/draios/sysdig-inspect/releases/download/#{version}/sysdig-inspect-mac-x86_64.zip"
  name "Sysdig Inspect"
  desc "Interface for container troubleshooting and security investigation"
  homepage "https://github.com/draios/sysdig-inspect"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Sysdig Inspect-darwin-x64/Sysdig Inspect.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/sysdig-inspect",
    "~/Library/Logs/Sysdig Inspect",
    "~/Library/Preferences/com.electron.sysdig-inspect.plist",
    "~/Library/Saved Application State/com.electron.sysdig-inspect.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
