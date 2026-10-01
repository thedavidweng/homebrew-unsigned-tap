cask "vidcutter" do
  version "6.0.5.1"
  sha256 "8d1556887f0b203ebcb7b6e13a33389afad173a2c73dbc906b69ece034218f02"

  url "https://github.com/ozmartian/vidcutter/releases/download/#{version}/VidCutter-#{version}-macOS.dmg"
  name "VidCutter"
  desc "Media cutter and joiner"
  homepage "https://github.com/ozmartian/vidcutter"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "VidCutter.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/VidCutter.app"],
        must_succeed: false
  end

  caveats do
    requires_rosetta
  end
end
