cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-30"
  sha256 arm:   "2ed3aee39b4c2e66664f4c3801d87f727c634d4487617a67e61a98b823ba52cf",
         intel: "e3fe9c01ed0b1bdee3dd584b73e21ca81223f40dc04b56a5941d33cc75cc0068"

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
