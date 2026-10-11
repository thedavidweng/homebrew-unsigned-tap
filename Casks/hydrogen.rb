cask "hydrogen" do
  version "1.2.7"
  sha256 "3c7427fadcb492da15786cb14f7b6b9728ebbc9fad7254eedffc0ffb85faf127"

  url "https://github.com/hydrogen-music/hydrogen/releases/download/#{version}/Hydrogen-#{version}.dmg"
  name "Hydrogen"
  desc "Drum machine and sequencer"
  homepage "http://www.hydrogen-music.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Hydrogen.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Hydrogen.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Application Support/Hydrogen"

  caveats do
    requires_rosetta
  end
end
