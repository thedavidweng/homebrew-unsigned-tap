cask "chromedriver" do
  arch arm: "arm64", intel: "x64"

  version "156.0.8078.47"
  sha256 arm:   "f42d25b984e2185ee48a628f0e76d49fcdf2fa83f20f7c286880dddeb4a28cc9",
         intel: "a2cc341313d8b14861b30a0aa1133bf8c975df7dc850b2cb50a052a1fcb4f1e9"

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
