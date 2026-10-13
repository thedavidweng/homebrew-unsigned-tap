cask "vassal" do
  version "3.7.29"
  sha256 "117f7fd1afbae8dd3a1dc9a4562dc74c0bc7153eea63d239740baaa67d1bb0f1"

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
