cask "operadriver" do
  version "153.0.8010.55"
  sha256 "c7cf02b4628903457b2540a61b8e743822bcc3d927d5f75424fe456d0deb9495"

  url "https://github.com/operasoftware/operachromiumdriver/releases/download/v.#{version}/operadriver_mac64.zip"
  name "OperaChromiumDriver"
  desc "Driver for Chromium-based Opera releases"
  homepage "https://github.com/operasoftware/operachromiumdriver"

  livecheck do
    url :url
    regex(/^v?\.?(\d+(?:\.\d+)+)$/i)
  end

  depends_on macos: :ventura

  binary "operadriver_mac64/operadriver"

  # No zap stanza required

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  caveats do
    requires_rosetta
  end
end
