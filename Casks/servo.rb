cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-06"
  sha256 arm:   "b4a3e81e48ade0cfd44ac4db6295486507c42104ce591682fdd5e97413eb197c",
         intel: "fa25da595591e67c6ea9faadd214c29f8ba960fa8a39c66ddb2458b3927191d0"

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
