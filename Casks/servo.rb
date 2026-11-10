cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-09"
  sha256 arm:   "40dbf67b27038f851382929c5ee929e877ffa7a3e89b66ccbca85fa063ca6718",
         intel: "9a98b341638f5cccec8504ac564c41e6830057b318a46de3fcc8a864967967b9"

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
