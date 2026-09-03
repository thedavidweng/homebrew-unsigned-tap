cask "armory" do
  version "0.96.5"
  sha256 "53d0286e54bad62309f3a79a33118f2d1f369be36f9a08b07e61d04aa39f6516"

  url "https://github.com/goatpig/BitcoinArmory/releases/download/v#{version}/armory_#{version}_osx.tar.gz"
  name "Armory"
  desc "Python-Based Bitcoin Software"
  homepage "https://btcarmory.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Armory.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  caveats do
    requires_rosetta
  end
end
