cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-21"
  sha256 arm:   "a41a158cae7be32698c2cd6b2581d1a5a68499bc793e831220097711452c37f6",
         intel: "644a7de41c50ca50df59c9590412413e9b4c7785f9d220853acacb9af089bd8c"

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
