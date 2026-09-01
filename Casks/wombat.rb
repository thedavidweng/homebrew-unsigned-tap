cask "wombat" do
  version "0.5.0"
  sha256 "a655f77a5e55b1fbea7f4855d8d536c52d701bdb1ac7c466e1e5656a208421bf"

  url "https://github.com/rogchap/wombat/releases/download/v#{version}/Wombat_v#{version}_Darwin_x86_64.dmg"
  name "Wombat"
  desc "Cross platform gRPC client"
  homepage "https://github.com/rogchap/wombat"


  depends_on :macos

  app "Wombat.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/Wombat"

  caveats do
    requires_rosetta
  end
end
