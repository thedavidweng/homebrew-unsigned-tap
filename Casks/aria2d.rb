cask "aria2d" do
  version "1.4.2,484"
  sha256 "5ca7e037d934eac8d6b545db375e23fec1cbfacd99705f0b8d08eb0f98643e17"

  url "https://github.com/xjbeta/Aria2D/releases/download/#{version.csv.first}/Aria2D.zip"
  name "Aria2D"
  desc "Aria2 GUI"
  homepage "https://github.com/xjbeta/Aria2D"

  livecheck do
    url "https://raw.githubusercontent.com/xjbeta/AppUpdaterAppcasts/master/Aria2D/Appcast.xml"
    strategy :sparkle do |items|
      items.map(&:nice_version)
    end
  end

  depends_on macos: :monterey

  app "Aria2D.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Aria2D.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Aria2D",
    "~/Library/Application Support/com.xjbeta.Aria2D",
    "~/Library/Preferences/com.xjbeta.Aria2D.plist",
    "~/Library/Saved Application State/com.xjbeta.Aria2D.savedState",
  ]
end
