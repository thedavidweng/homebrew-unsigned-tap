cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-14"
  sha256 arm:   "dd99aef2a4d312612ce6a0b890ce8cfd8ccff9d49d0c77a4ced1807def1529e4",
         intel: "73a377ab99bf181379446272d2b2cdc17a6019b8d1009cc0536720b00155a25e"

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
