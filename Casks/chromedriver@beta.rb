cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "159.0.8154.33"
  sha256 arm:   "41feb8a9b419084415161093b8b3377624329145557b083a1acf751c32249577",
         intel: "1f1d2b7890646e73f5ac83bf58a46b8bced50494ba2dbd852c1b66c11a3fc389"

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
