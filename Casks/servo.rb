cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-01"
  sha256 arm:   "3932cd8c18318fd67d4d378ffb724217994be2ce349951d57a6e82d2010b29db",
         intel: "da193a006d7efeaf6650f99774667a532574ca1f06ca2682209172d4e974fd46"

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
