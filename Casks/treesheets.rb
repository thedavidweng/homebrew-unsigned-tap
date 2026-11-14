cask "treesheets" do
  version "2.23.11"
  sha256 "e44bead1e5c137ec2b73f8cd93903d0d86974880902c95c1a3aec33b794823b8"

  url "https://github.com/aardappel/treesheets/releases/download/v#{version}/TreeSheets-#{version}-macOS.dmg"
  name "TreeSheets"
  desc "Hierarchical spreadsheet and outline application"
  homepage "https://strlen.com/treesheets/"

  livecheck do
    url :url
    regex(/TreeSheets[._-]v?(\d+(?:\.\d+)*)[._-]macOS\.dmg$/i)
    strategy :github_latest do |json, regex|
      json["assets"]&.map do |asset|
        match = asset["browser_download_url"]&.match(regex)
        next if match.blank?

        match[1]
      end
    end
  end

  depends_on :macos

  app "TreeSheets.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/TreeSheets.app"],
        must_succeed: false
  end

  uninstall quit: "dot3labs.TreeSheets"

  zap trash: [
    "~/Library/Preferences/com.strlen.TreeSheets.plist",
    "~/Library/Preferences/dot3labs.TreeSheets.plist",
    "~/Library/Preferences/TreeSheets Preferences",
    "~/Library/Saved Application State/dot3labs.TreeSheets.savedState",
  ]
end
