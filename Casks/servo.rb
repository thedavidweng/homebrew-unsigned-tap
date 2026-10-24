cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-23"
  sha256 arm:   "00f2443c71b4528c4ea40b603821252b140f50135a6a3eb0e29fd57d8e35cf22",
         intel: "3ac998d646489c905d0c2bbbd018115f2a183814dc2e524b29f15ed3f8a5a60e"

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
