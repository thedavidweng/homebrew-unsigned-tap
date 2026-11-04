cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "158.0.8127.18"
  sha256 arm:   "9fd0a5c45717692a52a5fb99b0c9f367d3f3402dad270e71d796bd89eadf75c0",
         intel: "49925dc84ecdebc8fc853e50d2859690332955b80a7b284b6aa39771f5255d87"

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
