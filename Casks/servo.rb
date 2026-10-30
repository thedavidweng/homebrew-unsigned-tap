cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-29"
  sha256 arm:   "b54210b11a68070c2f0111a5ff9407478014966f17dd8b81141e4a112c1f583a",
         intel: "c3ebd637455a78b54683edd7d9f520f6b5c82cd2a987a0c0ad119f881effacb5"

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
