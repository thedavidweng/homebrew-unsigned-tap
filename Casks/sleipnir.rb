cask "sleipnir" do
  version "4.6.6"
  sha256 :no_check

  url "https://www.fenrir-inc.com/services/download.php?file=Sleipnir.dmg"
  name "Sleipnir"
  desc "Web browser"
  homepage "https://www.fenrir-inc.com/jp/sleipnir/"

  livecheck do
    url "https://update.fenrir.co.jp/smartupdate/mac/sleipnir/appcast.xml"
    strategy :sparkle, &:short_version
  end

  depends_on :macos

  app "Sleipnir.app"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  caveats do
    requires_rosetta
  end
end
