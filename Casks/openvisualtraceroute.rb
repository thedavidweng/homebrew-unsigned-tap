cask "openvisualtraceroute" do
  version "2.0.0"
  sha256 "bf1fecac21fecde1100f495b0e4e5a166b552dcc8477ab1caf90d6f63c610977"

  url "https://downloads.sourceforge.net/openvisualtrace/#{version}/OpenVisualTraceRoute#{version}.dmg"
  name "OpenVisualTraceroute"
  desc "Visual networking tool"
  homepage "https://visualtraceroute.net/"

  livecheck do
    url :url
    regex(%r{url=.*?/OpenVisualTraceRoute[._-]?v?(\d+(?:\.\d+)+)\.dmg}i)
  end


  depends_on :macos

  app "OpenVisualTraceroute.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/ovtr"

  caveats do
    depends_on_java "8"
  end
end
