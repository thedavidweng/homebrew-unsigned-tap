cask "redream" do
  version "1.5.0"
  sha256 "e5253527a3705b4c99234ddf8ece59d19dfadb416822ad714f7009b82afc097b"

  url "https://redream.io/download/redream.x86_64-mac-v#{version}.tar.gz"
  name "redream"
  desc "Dreamcast emulator"
  homepage "https://redream.io/"

  livecheck do
    url "https://redream.io/download"
    regex(/redream\.x86_64-mac-v(\d+(?:\.\d+)*)\.t/i)
  end


  depends_on :macos

  app "redream.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/redream",
    "~/Library/Saved Application State/io.recompiled.redream.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
