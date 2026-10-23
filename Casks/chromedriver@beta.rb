cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "157.0.8103.15"
  sha256 arm:   "01527831b9c8c8c3f2630019aba4e268b80afa6224b6dfa0210bee6c5a427618",
         intel: "9440a96644d9fed6e2f6679b89d29d24718b6637c1ed6d19756389efa3aa436f"

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
