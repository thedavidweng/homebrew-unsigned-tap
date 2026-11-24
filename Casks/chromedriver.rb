cask "chromedriver" do
  arch arm: "arm64", intel: "x64"

  version "158.0.8127.88"
  sha256 arm:   "7f9653f99ff26c4649dd7dc771c0c5a28248d836dd8bae6e71227b3d35cfd642",
         intel: "593dedcdbf2efd7f28e4b3348879c4fb9c6bc03b64f66cc6ae941709ee632803"

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
