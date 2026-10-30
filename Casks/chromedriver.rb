cask "chromedriver" do
  arch arm: "arm64", intel: "x64"

  version "156.0.8078.80"
  sha256 arm:   "b5fe5abe5a82ca3ac49b3f2ea9e177b63f82fc3a4227883e0eaa9894a6bf3b7f",
         intel: "9036ec0135938aa4303c03f88307c749a0ae45448e3431e51e740fa21610ff75"

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
