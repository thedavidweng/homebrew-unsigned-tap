cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-26"
  sha256 arm:   "ff740da077989cd7db547377a299610e5794576fed6760325d5e6cb8c289b859",
         intel: "2b0032e6a6bef57a45190e66efd0824c936a2f685b79923337f7236e048b2dd8"

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
