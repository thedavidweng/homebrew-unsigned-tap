cask "operadriver" do
  version "150.0.7871.212"
  sha256 "6e11b896cbd19848717847792e90dd0600b5cb69aec93dc187480bedd14016be"

  url "https://github.com/operasoftware/operachromiumdriver/releases/download/v.#{version}/operadriver_mac64.zip"
  name "OperaChromiumDriver"
  desc "Driver for Chromium-based Opera releases"
  homepage "https://github.com/operasoftware/operachromiumdriver"

  livecheck do
    url :url
    regex(/^v?\.?(\d+(?:\.\d+)+)$/i)
  end

  depends_on :macos

  binary "operadriver_mac64/operadriver"

  # No zap stanza required

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  caveats do
    requires_rosetta
  end
end
