cask "chromedriver@beta" do
  arch arm: "arm64", intel: "x64"

  version "150.0.7871.46"
  sha256 arm:   "fe616458e12b959c23565a4c3b057392e80f8bcb7b59410d9e493d6fcd864f1b",
         intel: "2b7e464a905f20f59e4b27939c3b8d232fdde01817c584ac28cb28faf7a05886"

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
  depends_on :macos

  binary "chromedriver-mac-#{arch}/chromedriver"

  # No zap stanza required

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end
end
