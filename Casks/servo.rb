cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-04"
  sha256 arm:   "e33532625d6a3d8c58cd12c2d0a8a2838310e298dd22dce7354558fb3a916ba9",
         intel: "ba899be6da4e5ab1f12c052c0e9b2b0988d6e732ddfb06d3de70435279d34f51"

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
