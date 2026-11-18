cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "159.0.8154.13"
  sha256 arm:   "e283f22d50730336107287326bbe7e798bf87fdc6609d2b7e2a8e42b884ce7c6",
         intel: "48fc5b076117341a41a99e0cfc7b7cfb023bbf7dae5a2dc56efeb5c64fcc2ac5"

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
