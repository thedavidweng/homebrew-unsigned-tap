cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-12"
  sha256 arm:   "531c8ff2a60146904153ed6317c5f516249df7c2b29732a210cbb98fff34f6e9",
         intel: "6d2cbd7bb66a062fe2ba38788ccbb337ee63b327dacbbc6ffa4d2ac08db8486e"

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
