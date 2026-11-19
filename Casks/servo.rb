cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-18"
  sha256 arm:   "bde3e4b54a68b4081d68d717c0c1bc38d7a615e91f87dc47dd2dc08f6c9e687c",
         intel: "c27dc3e8c86eb1d9c7f0b2bce8d6ca8d95585bfdbf38e5253ad6944ed29ba555"

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
