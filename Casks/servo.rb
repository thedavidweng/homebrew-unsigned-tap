cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-26"
  sha256 arm:   "c9433b51773a07884dd75cad1a32308d47612b312de2ee3ffc9af34142b368fb",
         intel: "452b8746212656debe04655fa7aeed1ab6705c53f307a10da91baaacac32c359"

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
