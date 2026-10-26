cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-25"
  sha256 arm:   "e8fa5331d7972fb1f131ee855b6cd22d88f492822b1065050b412ed3153a2a27",
         intel: "4007a79565bba05185d24b8d8cd1cfe6f0a6d33309ff7df6f83dbc3e7062fee2"

  url "https://github.com/servo/servo-nightly-builds/releases/download/#{version}/servo-#{arch}-apple-darwin.dmg"
  name "Servo"
  desc "Parallel browser engine"
  homepage "https://servo.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:[.-]\d+)+)$/i)
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Servo.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Servo.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Application Support/Servo"
end
