cask "orca" do
  version "1.3.1"
  sha256 "79b1b346df9113cd56e545b223a73179801116ca9e009f3c5fe0fac97c0df1ab"

  url "https://github.com/plotly/orca/releases/download/v#{version}/mac-release.zip"
  name "Orca"
  desc "Generate images of interactive plotly charts"
  homepage "https://github.com/plotly/orca/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on :macos
  container nested: "orca-#{version}.dmg"

  app "orca.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/orca",
    "~/Library/Preferences/com.plotly.orca.plist",
  ]

  caveats do
    requires_rosetta
  end
end
