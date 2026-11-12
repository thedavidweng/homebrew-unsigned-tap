cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-11"
  sha256 arm:   "2695fcb85e162034ebdf51790adee5d037bf0ce8e24aaa16b4680bc682e304bb",
         intel: "2d3d1f88a73a6c5c9859e7d19478d22efea832e7271b6213c70d3e008fbd5129"

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
