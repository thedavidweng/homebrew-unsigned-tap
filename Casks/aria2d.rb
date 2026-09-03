cask "aria2d" do
  version "1.4.1,470"
  sha256 "71aea297a3e47294a1097506945ba943915bda2784f93eead53487b5ccea547c"

  url "https://github.com/xjbeta/Aria2D/releases/download/#{version.csv.first}%28#{version.csv.second}%29/Aria2D.zip"
  name "Aria2D"
  desc "Aria2 GUI"
  homepage "https://github.com/xjbeta/Aria2D"

  livecheck do
    url "https://raw.githubusercontent.com/xjbeta/AppUpdaterAppcasts/master/Aria2D/Appcast.xml"
    strategy :sparkle do |items|
      items.map(&:nice_version)
    end
  end

  depends_on macos: :big_sur

  app "Aria2D.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Aria2D",
    "~/Library/Application Support/com.xjbeta.Aria2D",
    "~/Library/Preferences/com.xjbeta.Aria2D.plist",
    "~/Library/Saved Application State/com.xjbeta.Aria2D.savedState",
  ]
end
