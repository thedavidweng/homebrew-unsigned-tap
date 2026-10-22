cask "uvtools" do
  arch arm: "arm64", intel: "x64"

  version "7.1.0"
  sha256 arm:   "fd6166e12463d219c1d32a98c88d00619df3eeac0bf291202868b78caa27bcbd",
         intel: "e12252d53479cf92c4dddb5f5688433b10353b987e17706cdbdfb06d1fd7501f"

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
