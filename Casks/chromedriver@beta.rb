cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "157.0.8103.6"
  sha256 arm:   "c3cfbaa00559e8d25f758402c9968a37e01eda86791c5e7b14adc059a7d943e6",
         intel: "c2371a1ffbf18bbcf4279abed432da91795f0acc4b967187128f836721951826"

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

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end
end
