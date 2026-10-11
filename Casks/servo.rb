cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-10"
  sha256 arm:   "84dfe65ed8d9cd7d56c295e81b9d45fd380bde245327ddc3c485a52911930a41",
         intel: "1208544560e559b457927b9dfee79ca94efea9ac5f89be84942a78457cc7f9e2"

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
