cask "netxms-console" do
  version "7.0.2"
  sha256 "fc1247b0d2e63410937c1a3ca06a4f0a286984916a637a5ad5d8caa76214673c"

  url "https://netxms.com/download/releases/#{version.major_minor}/nxmc-#{version}.dmg"
  name "NetXMS Management Console"
  desc "Network and infrastructure monitoring and management system"
  homepage "https://netxms.com/"

  livecheck do
    url "https://netxms.com/downloads/"
    regex(/href=.*?nxmc[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
  end

  depends_on :macos

  app "NetXMS #{version.major_minor}.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/NetXMS #{version.major_minor}.app"],
        must_succeed: false
  end

  zap trash: "~/.nxmc"
end
