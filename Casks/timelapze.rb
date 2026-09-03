cask "timelapze" do
  version "1.2.2"
  sha256 "5ab0fad611d6b627a10ee4db673fd74bbca1296e6b15ea152eabc8ca88a10187"

  url "https://github.com/wkaisertexas/ScreenTimeLapse/releases/download/v#{version}/TimeLapze.zip"
  name "TimeLapze"
  desc "Record screen and camera time lapses in a menu bar interface"
  homepage "https://github.com/wkaisertexas/ScreenTimeLapse"

  auto_updates true
  depends_on macos: :sonoma

  app "TimeLapze.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall quit: "com.smartservices.TimeLapze"

  zap trash: [
    "~/Library/Application Scripts/com.smartservices.TimeLapze",
    "~/Library/Containers/com.smartservices.TimeLapze",
    "~/Library/Preferences/com.smartservices.TimeLapze.plist",
  ]
end
