cask "uvtools" do
  arch arm: "arm64", intel: "x64"

  version "7.1.1"
  sha256 arm:   "1de1b19636d250eac4f20fd6b0031d2e63b2d0387f6456990ef70368b6040d07",
         intel: "10f39e7942be86fd86270f9b2fd2f9b9c13a077b3d82e602842bd22772d469c6"

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
