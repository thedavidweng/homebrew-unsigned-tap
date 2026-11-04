cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-03"
  sha256 arm:   "edc902767f13aa3735dcd87b92d5b64dcfe4f94103482d2b71c45d38384631bb",
         intel: "d04cc5d9cf49a8ccaec4d1e6db1f0a7b9426a60a646628155b1bc8d340afefda"

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
