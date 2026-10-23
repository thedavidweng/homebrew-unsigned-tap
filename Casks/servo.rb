cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-22"
  sha256 arm:   "ddce89b858a3d31f9d87dec1561fef214669e35eec27e31ae68ba858875d894c",
         intel: "ce7c8f3efb02fbf02dacd6572b0256076467216b1e5485e418e984bd7d1cd47d"

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
