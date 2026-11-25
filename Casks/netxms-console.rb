cask "netxms-console" do
  version "7.0.5"
  sha256 "fa06a13f79a169257c8bbf9fe0f9d4c7ad06a3789a0ad9e1bbe5c2c5b124eda2"

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
