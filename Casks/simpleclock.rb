cask "simpleclock" do
  version "1.1"
  sha256 "daac22a51eeb35dc29aaa0eb21cfa439a18aa0ea229316630c3395e156064740"

  url "https://github.com/Wandmalfarbe/Simple-Clock-Screensaver/releases/download/v#{version}/Simple-Clock-#{version}.saver.zip"
  name "Simple Clock Screensaver"
  desc "Simple analogue clock screensaver written entirely in Swift"
  homepage "https://github.com/Wandmalfarbe/Simple-Clock-Screensaver"

  depends_on :macos

  screen_saver "SimpleClock.saver"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
