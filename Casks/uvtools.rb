cask "uvtools" do
  arch arm: "arm64", intel: "x64"

  version "7.0.3"
  sha256 arm:   "67044d49e55309782c172928a574c524c95181ac4c51a0e9d34b77e36e936a2e",
         intel: "a5f1c8de7bb8317dc2f0fd64ff627e7f89a9ac9598facfab63c88edbbfc3f067"

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
