cask "uvtools" do
  arch arm: "arm64", intel: "x64"

  version "6.2.0"
  sha256 arm:   "a12dbd3c61050080301600baef43a4ef7c7be944ed6e33c092834b4b8d08948f",
         intel: "40a270c2a6b6c6ee71f2f73dcebab9bf9bead2b04525c0d357e04d3e957b9c43"

  url "https://github.com/sn4k3/UVtools/releases/download/v#{version}/UVtools_osx-#{arch}_v#{version}.zip"
  name "UVtools"
  desc "MSLA/DLP, file analysis, calibration, repair, conversion and manipulation"
  homepage "https://github.com/sn4k3/UVtools"

  auto_updates true
  depends_on macos: :ventura

  app "UVtools.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Preferences/com.UVtools.plist",
    "~/Library/Saved Application State/com.UVtools.savedState",
  ]
end
