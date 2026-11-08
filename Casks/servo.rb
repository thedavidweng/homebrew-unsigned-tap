cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-07"
  sha256 arm:   "7737d19f25afd16ac778a9d000878a6daf13303ff1f8eb4f84c1fb6c8074d997",
         intel: "108a2bbc4b7282fd36a7b2ff194384fd641af82723a149f266e8c65c104b2992"

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
