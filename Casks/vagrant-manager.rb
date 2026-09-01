cask "vagrant-manager" do
  version "2.7.1"
  sha256 "ad10795f36a2c0977ec8e278082f1f66624cc3b16f837dc72c0f1c063fefb4de"

  url "https://github.com/lanayotech/vagrant-manager/releases/download/#{version}/vagrant-manager-#{version}.dmg"
  name "Vagrant Manager"
  homepage "https://www.vagrantmanager.com/"


  depends_on :macos

  app "Vagrant Manager.app"

  uninstall quit: "lanayo.Vagrant-Manager"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Caches/lanayo.Vagrant-Manager",
    "~/Library/Preferences/lanayo.Vagrant-Manager.plist",
  ]

  caveats do
    requires_rosetta
  end
end
