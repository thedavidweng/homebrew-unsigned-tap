cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-13"
  sha256 arm:   "b07a54e02c6c69f89b5a72ee9135aba5dd7a89928108fb40b85e36fa56c6dada",
         intel: "0c770d58632afe0ed203b528e631ec12cde4bb0285a9174c4bc437d1e48146a1"

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
