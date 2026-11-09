cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-08"
  sha256 arm:   "bdb0fe4783e28fc74a542f7121067c4a4b9301f3a68fe4a3c4e2171d156c6f32",
         intel: "4fa74be7500e99fdc57f8baf584997ad4ef2fbbd6722d965fd4b0bc6cc193ed6"

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
