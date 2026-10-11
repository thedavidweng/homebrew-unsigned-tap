cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "156.0.8078.12"
  sha256 arm:   "a1d090500a02a05a5959a953ad4fea9362bcfe6db6fd150bffb761c625f9c99f",
         intel: "94750aadd9753e2cd49e939a266b2c3a9b1e604f4c462ce447e64f994e7e3f84"

  url "https://storage.googleapis.com/chrome-for-testing-public/#{version}/mac-#{arch}/chromedriver-mac-#{arch}.zip"
  name "ChromeDriver"
  desc "Automated testing of webapps for Google Chrome"
  homepage "https://chromedriver.chromium.org/"

  livecheck do
    url "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json"
    strategy :json do |json|
      json.dig("channels", "Beta", "version")
    end
  end

  conflicts_with cask: "chromedriver"
  depends_on :macos

  binary "chromedriver-mac-#{arch}/chromedriver"

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end
end
