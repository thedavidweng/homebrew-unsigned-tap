cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-27"
  sha256 arm:   "1679c6adfccf8434e281a90dd1db39eb8ce9e2684e18d85e8f15961e50316b3a",
         intel: "96aa2d9052d8303c3acd1090957e8dcbd494507559a9a2971576a06380bfce8d"

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
