cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-15"
  sha256 arm:   "e5a19019291264fca930f7bf7f867986294a24cfc952ded06ebf8198f4537475",
         intel: "1f41786a67ef7a6acc7bfdd5e52562ad860ad6f92709883493120515d1a331a7"

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
