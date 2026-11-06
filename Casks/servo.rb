cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-05"
  sha256 arm:   "90cfd86037d3def6906f7856a74a7740a3365295105443a793e81ac9cde90604",
         intel: "b728092b46d94dfbaf52c8935e903cffc185e25e049636812a16e0bcf9185851"

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
