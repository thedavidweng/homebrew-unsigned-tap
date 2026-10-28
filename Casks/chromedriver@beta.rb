cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "158.0.8127.2"
  sha256 arm:   "f6d8f6b99ace3835359d3ffc851b21ae7d4a0a1b4d1862a812515e7630e03125",
         intel: "7a0616a6e41502c9ddc3573d45322f743f4027c505bd49d13e7f73c54db0e7c0"

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
  depends_on macos: :ventura

  binary "chromedriver-mac-#{arch}/chromedriver"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
