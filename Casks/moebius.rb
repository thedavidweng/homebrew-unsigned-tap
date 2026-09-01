cask "moebius" do
  version "1.0.29"
  sha256 "014e355767fa27796a6f5f5778b608a3a802ba064655c23776fa89f0dd1163ba"

  url "https://github.com/blocktronics/moebius/releases/download/#{version}/Moebius.dmg"
  name "Moebius"
  desc "ANSI editor"
  homepage "https://blocktronics.github.io/moebius/"


  depends_on :macos

  app "Moebius.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Moebius",
    "~/Library/Preferences/org.andyherbert.moebius.plist",
  ]

  caveats do
    requires_rosetta
  end
end
