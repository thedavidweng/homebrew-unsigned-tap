cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-20"
  sha256 arm:   "f117cdcdacf7e59d998de76faed3d032b08cd5e0d569f89729e3bd56623ab90c",
         intel: "61b246e5dd1f9877402b786431759f9100e05d016003617deac7f093c8580149"

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
