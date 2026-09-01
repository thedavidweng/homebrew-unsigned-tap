cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-06-30"
  sha256 arm:   "1507c5a57ce0d067fbe5a036390b6a2e7dc6b558d6b5a7ce0c7a982fee0d62ef",
         intel: "64b7b63df7ca812512d99a39ca306f21f9d97a0379261952d3d4c912004f17c2"

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

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/Servo"
end
