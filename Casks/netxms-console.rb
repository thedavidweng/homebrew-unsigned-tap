cask "netxms-console" do
  version "7.0.0"
  sha256 "28cecc363170eb822a02d2e51df8afa923f2b01470dddd1be6341ab5f5deec07"

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
