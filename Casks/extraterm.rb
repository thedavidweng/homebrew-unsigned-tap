cask "extraterm" do
  version "0.81.4"
  sha256 "214bd9bb54fcb8c8cd97c8ea401898adac1a205b5fba74b406178757dbeae814"

  url "https://github.com/sedwards2009/extraterm/releases/download/v#{version}/ExtratermQt_#{version}.dmg"
  name "Extraterm"
  desc "Swiss army chainsaw of terminal emulators"
  homepage "https://extraterm.org/"

  livecheck do
    url :url
    regex(/^ExtratermQt[._-]v?(\d+(?:\.\d+)+)\.dmg$/i)
    strategy :github_releases do |releases, regex|
      releases.reject { |release| release["draft"] || release["prerelease"] }.flat_map do |release|
        release["assets"].filter_map { |asset| asset["name"][regex, 1] }
      end
    end
  end

  depends_on :macos

  app "ExtratermQt.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/ExtratermQt.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/extraterm",
    "~/Library/Preferences/com.electron.extraterm*.plist",
  ]

  caveats do
    requires_rosetta
  end
end
