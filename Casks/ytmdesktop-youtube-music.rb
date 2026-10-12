cask "ytmdesktop-youtube-music" do
  arch arm: "arm64", intel: "x64"

  minimum_macos = :monterey

  on_monterey :or_older do
    version "2.0.11"
    sha256 arm:   "a316f258d35f9f2b13c2bc883eafbe70cc50960060af4418e969c9466d83daba",
           intel: "beca2759e23325cfdfc813c0d4a3b2e38d3be1b72bd87471a404c97b4d6927f7"

    url "https://github.com/ytmdesktop/ytmdesktop/releases/download/v#{version}/YouTube.Music.Desktop.App-darwin-#{arch}-#{version}.zip"

    livecheck do
      skip "Version 2.0.11 is the last release compatible with macOS Monterey"
    end
  end
  on_ventura :or_newer do
    version "2.0.12"
    sha256 arm:   "9932d6eedd985c3068068449f6e73f105c37e39a93433d880eb17a5a83963f9b",
           intel: "f4539ffc4a30ed71976dac2e45f2fa90d9858b3975bc4cf2c7b0b33407a001d0"

    url "https://github.com/ytmdesktop/ytmdesktop/releases/download/v#{version}/YouTube.Music.Desktop.App-darwin-#{arch}-#{version}.zip"

    # Not every GitHub release provides a file for both architectures, so we check
    # multiple recent releases instead of only the "latest" release.
    livecheck do
      url :url
      regex(/Desktop[._-]App[._-]darwin[._-](?:#{arch})[._-]v?(\d+(?:\.\d+)+)\.(?:dmg|pkg|zip)$/i)
      strategy :github_releases do |json, regex|
        json.map do |release|
          next if release["draft"] || release["prerelease"]

          release["assets"]&.map do |asset|
            match = asset["name"]&.match(regex)
            next if match.blank?

            match[1]
          end
        end.flatten
      end
    end

    minimum_macos = :ventura
  end

  name "YouTube Music Desktop App"
  desc "YouTube music client"
  homepage "https://ytmdesktop.app/"

  depends_on macos: minimum_macos

  app "YouTube Music Desktop App.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/YouTube Music Desktop App.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/app.ytmd.plist",
    "~/Library/Saved Application State/app.ytmd.savedState",
  ]
end
