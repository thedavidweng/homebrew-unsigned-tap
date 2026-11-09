cask "chromedriver" do
  arch arm: "arm64", intel: "x64"

  version "157.0.8103.50"
  sha256 arm:   "a248565ad9769b52fd55e04c6e82eb157ca414c2d6eae3238135ef2228024845",
         intel: "59df949c3e7c0383bb8f0609c00107e4444c8778ddc1d61362d8c118a05e7bae"

  url "https://storage.googleapis.com/chrome-for-testing-public/#{version}/mac-#{arch}/chromedriver-mac-#{arch}.zip"
  name "ChromeDriver"
  desc "Automated testing of webapps for Google Chrome"
  homepage "https://chromedriver.chromium.org/"

  livecheck do
    url "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json"
    strategy :json do |json|
      json.dig("channels", "Stable", "version")
    end
  end

  conflicts_with cask: "chromedriver@beta"
  depends_on macos: :ventura

  binary "chromedriver-mac-#{arch}/chromedriver"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
