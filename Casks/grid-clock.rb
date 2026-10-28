cask "grid-clock" do
  version "0.0.5"
  sha256 "eb9f5b480308786ca2a7277c727d6b3478563c68bf883305f99976682dc23ee9"

  url "https://github.com/chrstphrknwtn/grid-clock-screensaver/releases/download/#{version}/Grid.Clock.#{version}.saver.zip"
  name "Grid Clock Screensaver"
  desc "Unofficial restore of grid-clock"
  homepage "https://github.com/chrstphrknwtn/grid-clock-screensaver"

  depends_on :macos

  screen_saver "Grid Clock.saver"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
