cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-12"
  sha256 arm:   "5183d51ba5fe75ca38a9a2d56c0f4dc583923379877c6ef11937757ad2581da8",
         intel: "a5eaaad23397273d0635377a62a15340977ee815e261349c8406f89f7a4455ca"

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
