cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-27"
  sha256 arm:   "8bd2f23b7b8c664155ce162a8fa032261d1efa381c71e677e0112b49a4cbdaba",
         intel: "256eea33faeea910ad4e46b938260ade2e7d380d60f4cfde7bc1e1df24a261ef"

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
