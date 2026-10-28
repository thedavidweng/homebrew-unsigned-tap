cask "epoch-flip-clock" do
  version "0.0.5"
  sha256 "90fa0ace6b13b47a12dc89a56c33d9add1140fecbd6bdd0c905d396fa093b02d"

  url "https://github.com/chrstphrknwtn/epoch-flip-clock-screensaver/releases/download/#{version}/Epoch.Flip.Clock.#{version}.saver.zip"
  name "Epoch Flip Clock Screensaver"
  desc "Flip clock screensaver"
  homepage "https://github.com/chrstphrknwtn/epoch-flip-clock-screensaver/"

  depends_on :macos

  screen_saver "Epoch Flip Clock.saver"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required
end
