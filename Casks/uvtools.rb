cask "uvtools" do
  arch arm: "arm64", intel: "x64"

  version "7.1.2"
  sha256 arm:   "0fe329344102ab0326c143ea9200ec6f0fdb9708e747c178bc34b6e46cc0961f",
         intel: "ffb14e9055d85b80c2c8556b6573d5560d911257f2eddc61d688dc7b9bedebc6"

  url "https://github.com/sn4k3/UVtools/releases/download/v#{version}/UVtools_osx-#{arch}_v#{version}.zip"
  name "UVtools"
  desc "MSLA/DLP, file analysis, calibration, repair, conversion and manipulation"
  homepage "https://github.com/sn4k3/UVtools"

  auto_updates true
  depends_on macos: :ventura

  app "UVtools.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/UVtools.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.UVtools.plist",
    "~/Library/Saved Application State/com.UVtools.savedState",
  ]
end
