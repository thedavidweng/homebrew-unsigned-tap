cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-25"
  sha256 arm:   "8c664df9cfc04b355b09f3582ae2c623354d1ef61080e46706e147e54c598407",
         intel: "590df7535b1530991754f9dc4a1754a0b0b591931d157ff733772857dec604b6"

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
