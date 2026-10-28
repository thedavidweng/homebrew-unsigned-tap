cask "operadriver" do
  version "155.0.8059.85"
  sha256 "76de53b32183983e79c39824f19ca17304485374e3b66dd9e24625d143ae9ac0"

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

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap :not_required

  caveats do
    requires_rosetta
  end
end
