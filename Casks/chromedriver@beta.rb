cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "159.0.8154.6"
  sha256 arm:   "508c01298f1afb1f0d9bc1e9e8f57d3e686415ea31b4fa26129d1d1d4ed4824b",
         intel: "6ccd8cc79db64b26cb053eef3e0b2bca849ed75de3d1dee4d772b4f60317fda4"

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
