cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-08-30"
  sha256 arm:   "306c27f20bb3f3833a97070baae087b77c88ad5318b8975531e4ee7c576f32f0",
         intel: "ed721a34485bd59171d8c62c959cb485bc7a7c627e348da32f860c0d8b311aa7"

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
