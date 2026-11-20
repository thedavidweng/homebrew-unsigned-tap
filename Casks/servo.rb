cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-19"
  sha256 arm:   "fc0db79ae2304f74b241956eb788089b729afdc6cc2123c32dbe862d9fb94c48",
         intel: "33cb659eb8a199ee5906580af05da4525021ad54d974347cbaffe9984d8bb0a6"

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
