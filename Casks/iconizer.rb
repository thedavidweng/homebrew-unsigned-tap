cask "iconizer" do
  version "2020.11.0"
  sha256 "abaffdea473f4d3cd7d763fcb3846fbb752b87949e6ef7d273a95b6f5c5c1e06"

  url "https://github.com/raphaelhanneken/iconizer/releases/download/#{version}/Iconizer.dmg"
  name "Iconizer"
  desc "Xcode asset catalog creator"
  homepage "https://raphaelhanneken.com/iconizer/"

  livecheck do
    url "https://raphaelhanneken.github.io/iconizer/sparkle/appcast.xml"
    strategy :sparkle, &:short_version
  end


  auto_updates true
  depends_on :macos

  app "Iconizer.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Preferences/com.raphaelhanneken.iconizer.plist"
end
