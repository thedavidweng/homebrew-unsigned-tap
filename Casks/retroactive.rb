cask "retroactive" do
  version "3.0"
  sha256 "7883c7d1be0ef7a82885e52119afa2bb1d34a0c9352c806da9a253a0b5e5bafb"

  url "https://github.com/cormiertyshawn895/Retroactive/releases/download/#{version}/Retroactive.#{version}.zip"
  name "Retroactive"
  desc "Run Apple apps on incompatible OS versions"
  homepage "https://github.com/cormiertyshawn895/Retroactive"


  depends_on :macos

  app "Retroactive #{version}/Retroactive.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap delete: "~/Library/Caches/com.retroactive.Retroactive"

  caveats do
    requires_rosetta
  end
end
