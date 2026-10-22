cask "librecad" do
  arch arm: "-arm64"

  version "2.2.1.6"
  sha256 arm:   "2c5049f5d38346b6152e5b000bb60060f3a2113484bba4bcb388cb690f275879",
         intel: "b46eb69effae096b1fd1e85d0aa1b037a71661617ca733f607f4e9d681c9c770"

  url "https://github.com/LibreCAD/LibreCAD/releases/download/v#{version.csv.first}/LibreCAD-v#{version.csv.second || version.csv.first}#{arch}.dmg"
  name "LibreCAD"
  desc "CAD application"
  homepage "https://librecad.org/"

  livecheck do
    url :url
    regex(/^LibreCAD[._-]v?(\d+(?:[.-]\d+)+(?:-\d+-g\h+)?)#{arch}\.dmg$/i)
    strategy :github_releases do |json, regex|
      json.map do |release|
        next if release["draft"] || release["prerelease"]

        tag = release["tag_name"]&.delete_prefix("v")

        release["assets"]&.map do |asset|
          match = asset["name"]&.match(regex)
          next tag if match.blank?

          (match[1] == tag) ? tag : "#{tag},#{match[1]}"
        end
      end.flatten
    end
  end

  depends_on :macos

  app "LibreCAD.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/LibreCAD.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/LibreCAD",
    "~/Library/Preferences/com.librecad.LibreCAD.plist",
    "~/Library/Saved Application State/com.yourcompany.LibreCAD.savedstate",
  ]
end
