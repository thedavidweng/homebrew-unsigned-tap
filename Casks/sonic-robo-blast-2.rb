cask "sonic-robo-blast-2" do
  # NOTE: "2" is not a version number, but an intrinsic part of the product name
  version "2.2.15"
  sha256 "9e9e998227a9034aa844f13d5b703ec765d6c2fdde9720de1ea778b166ef7fb6"

  url "https://github.com/STJr/SRB2/releases/download/SRB2_release_#{version}/SRB2-#{version}-macOS-Installer.dmg"
  name "Sonic Robo Blast 2"
  desc "3D open-source Sonic the Hedgehog fangame built using a Doom Legacy port of Doom"
  homepage "https://www.srb2.org/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on macos: :big_sur

  app "Sonic Robo Blast 2.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/srb2"
end
