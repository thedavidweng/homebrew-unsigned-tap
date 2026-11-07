cask "brewtarget" do
  version "5.2.3"
  sha256 "a3d63dcec6fd2535ab506633f35285a1385aa497ce649283317b23b77c38713f"

  url "https://github.com/Brewtarget/brewtarget/releases/download/v#{version}/brewtarget_#{version}_MacOS.dmg"
  name "brewtarget"
  desc "Beer recipe creation tool"
  homepage "https://www.brewtarget.beer/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :tahoe

  app "brewtarget_#{version}_MacOS.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/brewtarget_#{version}_MacOS.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/brewtarget",
    "~/Library/Preferences/com.brewtarget.Brewtarget.plist",
    "~/Library/Saved Application State/com.brewtarget.Brewtarget.savedState",
  ]
end
