cask "worldpainter" do
  version "2.27.1"
  sha256 "f2af630b5ee0e477b2357e00e5c25824cb32286764377abb49935b9f15557317"

  url "https://www.worldpainter.net/files/worldpainter_#{version}.tgz"
  name "WorldPainter"
  desc "Interactive map generator for Minecraft"
  homepage "https://www.worldpainter.net/"

  livecheck do
    url :homepage
    regex(%r{href=.*?/files/worldpainter[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  depends_on :macos

  app "WorldPainter.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall quit: "com.install4j.4144-4862-0472-7103.67"

  zap trash: "~/Library/Application Support/WorldPainter"
end
