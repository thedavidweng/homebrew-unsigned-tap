cask "netxms-console" do
  version "7.0.1"
  sha256 "3e1550eb61bcb088bff1dea5033efbd7a6c3ac015278704da7f49172ccf60ffd"

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
