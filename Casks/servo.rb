cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-17"
  sha256 arm:   "f1cc6d04e5b9deeab69bcc9e5d63c8c5ca2fdc3524f9d7dab70f42eb7396cd50",
         intel: "bdabb6260783a32b0559a0e77b7923c1f89c00d5c432dad9f8cb38e0b834f2b2"

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
