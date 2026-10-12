cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-11"
  sha256 arm:   "28edbe706fa39bbb1392504af6d1f736174ebf82ac59bbd1c006db1f3bc4b10e",
         intel: "f64a70cd8124d1a14f70e3bd35872cafd9af49fedbff86753c1f092267281743"

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
