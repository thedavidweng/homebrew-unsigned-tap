cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-21"
  sha256 arm:   "35c292456eed8bd4d829321ce6037a7e12e5d5dc63c467ee02a44fee8f0699d6",
         intel: "c2e4e5e94d4f7968d1aee67c5eae3fc60018758b1c5bd9af32c0f44c0731135c"

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
