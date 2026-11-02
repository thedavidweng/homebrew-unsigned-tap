cask "quickhash" do
  version "3.3.4,01,11,2023"
  sha256 "d5b73524b0d62a7f100f7a6f976eaad98968f03f20f6d6b6c28040f9c255a884"

  url "https://github.com/tedsmith/quickhash/releases/download/v#{version.csv.first}/QuickHash-Gui-AppleOSX-v#{version.csv.first}.zip"
  name "Quickhash"
  desc "Data hashing tool"
  homepage "https://www.quickhash-gui.org/"

  livecheck do
    url :url
    strategy :github_latest do |json|
      release = json["tag_name"]&.delete_prefix("v")
      next if release.blank? || json["assets"].none? do |asset|
        asset["name"] == "QuickHash-Gui-AppleOSX-v#{release}.zip"
      end

      date = Time.iso8601(json["published_at"]).utc.strftime("%d,%m,%Y")
      "#{release},#{date}"
    end
  end

  depends_on :macos
  container nested: "Quickhash-GUI_#{version.csv.second}#{version.csv.third}#{version.csv.fourth}.dmg"

  app "Quickhash-GUI.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Quickhash-GUI.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.Quickhash-GUI",
    "~/Library/Saved Application State/www.Quickhash-GUI.org.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
