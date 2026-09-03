cask "discretescroll" do
  version "1.2.1"
  sha256 "f2cc275e4537811bf35b2cec2128c086eefbe613c3b79b08819f4f966f1f7a60"

  url "https://github.com/emreyolcu/discrete-scroll/releases/download/v#{version}/DiscreteScroll.zip"
  name "DiscreteScroll"
  desc "Utility to fix a common scroll wheel problem"
  homepage "https://github.com/emreyolcu/discrete-scroll"

  depends_on :macos

  app "DiscreteScroll.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Preferences/com.emreyolcu.DiscreteScroll.plist"
end
