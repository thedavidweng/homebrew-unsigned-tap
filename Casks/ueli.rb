cask "ueli" do
  arch arm: "-arm64"

  version "9.29.0"
  sha256 arm:   "b6d10e9e86785bda386ecb0665e7b4e95a3a32b68b99d2769f47eeb3e6a97513",
         intel: "c0c31afac07bd93c1104cebf16bb127070be67155d17961bfbec43da1e6e3a5c"

  url "https://github.com/oliverschwendener/ueli/releases/download/v#{version}/Ueli-#{version}#{arch}.dmg"
  name "Ueli"
  desc "Keystroke launcher"
  homepage "https://ueli.app/"


  depends_on macos: :monterey

  app "ueli.app"

  uninstall quit: "ueli"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/ueli",
    "~/Library/Logs/ueli",
    "~/Library/Preferences/com.electron.ueli.plist",
  ]
end
