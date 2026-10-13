cask "google-trends" do
  version "1.0"
  sha256 :no_check

  url "https://dl.google.com/dl/trends/screensaver/GoogleTrendsScreensaver.dmg"
  name "Google Trends Screensaver"
  desc "Unofficial restore of google-trends"
  homepage "https://trends.google.com/trends/hottrends/visualize"

  livecheck do
    url :url
    strategy :extract_plist
  end

  depends_on :macos

  screen_saver "Google Trends.saver"

  # No zap stanza required

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end
end
