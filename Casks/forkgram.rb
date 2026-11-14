cask "forkgram" do
  arch arm: "arm64", intel: "x86"

  version "7.4.4"
  sha256 arm:   "90b23a7a6e61e429228dbf94bb8c03f22059a500563fe98862c8fc89af4649f1",
         intel: "6bc082cb4c7411e97569eab43f2a385feca61592ab826b8d866e160149d6b25f"

  url "https://github.com/Forkgram/tdesktop/releases/download/v#{version}/Forkgram.macOS.no.auto-update_#{arch}.zip"
  name "Forkgram"
  desc "Fork of Telegram Desktop"
  homepage "https://github.com/Forkgram/"

  # Not every GitHub release provides a file for macOS, so we check multiple
  # recent releases instead of only the "latest" release.
  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases do |json, regex|
      file_regex = /^Forkgram[._-]macOS[._-].*?#{arch}\.zip$/i

      json.map do |release|
        next if release["draft"] || release["prerelease"]
        next unless release["assets"]&.any? { |asset| asset["name"]&.match?(file_regex) }

        match = release["tag_name"]&.match(regex)
        next if match.blank?

        match[1]
      end
    end
  end

  conflicts_with cask: "forkgram@legacy"
  depends_on macos: :monterey

  app "Forkgram.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Forkgram.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Forkgram Desktop",
    "~/Library/Preferences/com.tdesktop.Telegram.plist",
  ]
end
