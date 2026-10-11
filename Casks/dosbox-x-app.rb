cask "dosbox-x-app" do
  arch arm: "arm64", intel: "x86_64"

  version "2026.08.02"
  sha256 arm:   "a2f5f9ace00bb5fccac8cc0644bc5930958a932be139744866e902e0944fdd6e",
         intel: "91363407ec8841771b5ca77fc65a9c9b6383752531202c8abe929809c56d5e75"

  url "https://github.com/joncampbell123/dosbox-x/releases/download/dosbox-x-v#{version.csv.first}/dosbox-x-macosx-#{arch}-#{version.csv.second || version.csv.first}.zip"
  name "DOSBox-X"
  desc "Fork of the DOSBox project"
  homepage "https://github.com/joncampbell123/dosbox-x"

  livecheck do
    url :url
    regex(/^dosbox-x-v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases do |json, regex|
      file_regex = /^dosbox-x-macosx?-#{arch}[._-]v?(\d+(?:\.\d+)+)\.zip$/i

      json.filter_map do |release|
        next if release["draft"] || release["prerelease"]

        tag_match = release["tag_name"].match(regex)
        next unless tag_match

        asset = release["assets"].find { |item| item["name"].match?(file_regex) }
        next unless asset

        file_version = asset["name"].match(file_regex)[1]
        tag_version = tag_match[1]
        (tag_version == file_version) ? tag_version : "#{tag_version},#{file_version}"
      end
    end
  end

  depends_on :macos

  app "dosbox-x/dosbox-x.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/dosbox-x.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.dosbox-x.plist",
    "~/Library/Preferences/mapper-dosbox-x.map",
  ]
end
