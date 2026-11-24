cask "forkgram" do
  arch arm: "arm64", intel: "x86"

  version "7.4.6"
  sha256 arm:   "11581d91cbe9bdfb3e92e60d715d77a629201b76c7d9d2690e59b69e5ec28ebe",
         intel: "107a6aa5bfa7e72c59d02dad9ce72465247ab98fb8175177e4b93198f3aa2a88"

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
