cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-24"
  sha256 arm:   "5cc8dfbf9df2780acc0e214eaa392f202b5c8f13b5d9d08dc362c4ca656965ba",
         intel: "1cde92ef546001846211328b902577eebb3af1af46173c997cae8f0829c87850"

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
