cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-10-28"
  sha256 arm:   "51320686c0313695e53366e9d31192cc8cecc729feb2ac1fb8c8fb71b9cdd04b",
         intel: "788d9d427926319e985035b08bf2e3c3284a7cb9b474c1c78197e8e733cccabd"

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
