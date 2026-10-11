cask "chromedriver" do
  arch arm: "arm64", intel: "x64"

  version "155.0.8059.39"
  sha256 arm:   "765c1a4c3e5eeca0e8a5eb5d0810998152394f1eb8c96ac7a7e711c97220e8f3",
         intel: "f99a8d5580796a8c3d2177bfc3baeb49702e71e7b0953149d4b1674cc8d844a8"

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
  depends_on :macos

  binary "chromedriver-mac-#{arch}/chromedriver"

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end
end
