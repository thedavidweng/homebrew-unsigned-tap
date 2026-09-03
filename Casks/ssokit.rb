cask "ssokit" do
  version "1.2.1"
  sha256 "830006cbb59dc3529dfae91f30ee1b1362f9be5952a599e9083d5fcaed710e34"

  url "https://github.com/rangaofei/SSokit-qmake/releases/download/#{version}/SSokit_#{version}.dmg"
  name "SSokit"
  desc "TCP and UDP debug tool"
  homepage "https://github.com/rangaofei/SSokit-qmake"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "SSokit.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Preferences/cn.rangaofei.SSokit.plist"

  caveats do
    requires_rosetta
  end
end
