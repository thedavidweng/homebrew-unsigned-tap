cask "vassal" do
  version "3.8.1"
  sha256 "f1f49af655d12d81d0421c1a4b427ffdd1c160cb6b4d61228f63281a088f1ed9"

  url "https://github.com/vassalengine/vassal/releases/download/#{version}/VASSAL-#{version}-macos-universal.dmg"
  name "VASSAL"
  desc "Board game engine"
  homepage "https://www.vassalengine.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "VASSAL.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/VASSAL.app"],
        must_succeed: false
  end

  uninstall quit: "org.vassalengine.vassal"

  zap trash: "~/Library/Application Support/VASSAL"
end
