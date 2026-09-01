cask "aegisub" do
  version "3.4.2"
  sha256 "cbbfd3276e0414b540f6b1bc12a69abd6b8a96b0a452de3b08c290d553754ad3"

  url "https://github.com/TypesettingTools/Aegisub/releases/download/v#{version}/Aegisub-#{version}.dmg"
  name "Aegisub"
  desc "Create and modify subtitles"
  homepage "https://github.com/TypesettingTools/Aegisub/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on macos: :ventura

  app "Aegisub.app"

  uninstall quit: "com.aegisub.aegisub"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Aegisub",
    "~/Library/Preferences/com.aegisub.aegisub.plist",
    "~/Library/Saved Application State/com.aegisub.aegisub.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
