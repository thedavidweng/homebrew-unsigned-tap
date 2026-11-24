cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-23"
  sha256 arm:   "c4049d1ff1680e3352fbd7e894c72e491535364bd5b9a2e64fe0e59e4754e6c1",
         intel: "d76366a27e6bce10d42fddd55b244ed5bb3a185e48e6a33a998b68f6612c472d"

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
