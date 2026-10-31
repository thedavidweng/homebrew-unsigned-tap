cask "vassal" do
  version "3.8.0"
  sha256 "6b3c9cfea0ccbcd0390d4df3f321e338283cc0274e829025fb2e40769bd8f467"

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
