cask "manuskript" do
  version "0.16.1"
  sha256 "f67f3f44fee26259c04eb2df24b7a85b71c9963be1fe93d5c24e738af4a2d2af"

  url "https://github.com/olivierkes/manuskript/releases/download/#{version.major_minor_patch}/manuskript-#{version}-osx.dmg"
  name "Manuskript"
  desc "Tool for writers"
  homepage "https://www.theologeek.ch/manuskript/"

  livecheck do
    url :url
    regex(/^manuskript[._-]v?(\d+(?:\.\d+)+)[._-]osx\.dmg$/i)
    strategy :github_releases do |releases, regex|
      releases.reject { |release| release["draft"] || release["prerelease"] }.flat_map do |release|
        release["assets"].filter_map { |asset| asset["name"][regex, 1] }
      end
    end
  end

  depends_on :macos

  app "manuskript.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/manuskript.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/manuskript",
    "~/Library/Preferences/ch.theologeek.www.manuskript.plist",
    "~/Library/Preferences/com.manuskript.manuskript.plist",
    "~/Library/Saved Application State/ch.theologeek.manuskript.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
