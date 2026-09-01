cask "xaos" do
  version "4.3.5"
  sha256 "ef54cf7f01bf8f05cffcf20e782159c4c1545fbc2be5937222dbc5d324a66408"

  url "https://github.com/xaos-project/XaoS/releases/download/release-#{version}/XaoS-#{version}.dmg"
  name "GNU XaoS"
  desc "Real-time interactive fractal zoomer"
  homepage "https://xaos-project.github.io/"

  livecheck do
    url :url
    regex(/^release[._-]v?(\d+(?:\.\d+)+)$/i)
  end


  depends_on macos: :ventura

  app "XaoS.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Preferences/net.sourceforge.xaos.XaoS.plist"

  caveats do
    requires_rosetta
  end
end
