cask "dyn-updater" do
  version "5.5.0"
  sha256 "70cb2600907b05adf5a912baaee7512b6d70331405c551414889a49608a1fab9"

  url "http://cdn.dyn.com/dynupdater/DynUpdater-#{version}.zip"
  name "Dyn Updater"
  desc "Automatic dynamic DNS update client"
  homepage "https://dyn.com/updater/"

  livecheck do
    url "http://cdn.dyn.com/dynupdater/appcast.xml"
    strategy :sparkle
  end

  depends_on :macos

  app "Dyn Updater.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  caveats do
    requires_rosetta
  end
end
