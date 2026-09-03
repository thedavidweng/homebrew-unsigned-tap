cask "transmission-remote-gui" do
  version "5.18.0"
  sha256 "fe32f0cdd5c8f9777bace0eceb92d6b269a2b20210f4cc0552112861ddead759"

  url "https://github.com/transmission-remote-gui/transgui/releases/download/v#{version}/transgui-#{version}.dmg"
  name "Transmission Remote GUI"
  desc "Remote control for Transmission downloads"
  homepage "https://github.com/transmission-remote-gui/transgui"

  depends_on :macos

  app "Transmission Remote GUI.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall quit: "com.transgui"

  zap trash: [
    "~/.config/Transmission Remote GUI",
    "~/Library/Preferences/com.transgui.plist",
    "~/Library/Saved Application State/com.transgui.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
