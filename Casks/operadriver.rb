cask "operadriver" do
  version "154.0.8037.99"
  sha256 "ba0f635edd52b20dc9002514bf6dee2e0c2234f8c4c723bcea430e5442df5c7c"

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
