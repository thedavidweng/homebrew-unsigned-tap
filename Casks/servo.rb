cask "servo" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026-11-22"
  sha256 arm:   "502fed7a2fb33788537a967949b514f3abde4104957bdf081820d7a5a8030b10",
         intel: "7c179972093604a37704b42e22bd31e14d355ec1b0aecf5032f24e783088423f"

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
