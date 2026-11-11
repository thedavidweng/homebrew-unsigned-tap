cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-10"
  sha256 arm:   "63e43c44c54fd7da206b3d8cd75bc4d3066af45f810894109c3e74554fc52fed",
         intel: "338624bcc6a77c32624125fad5342c0b1725f8f57f7e846196fc7050876b983f"

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
