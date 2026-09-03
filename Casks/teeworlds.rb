cask "teeworlds" do
  version "0.7.5"
  sha256 "a79155c8bd7a0ce08457760f1ce37d8b7611f86717659bb3d90cd0e2dae5194b"

  url "https://downloads.teeworlds.com/teeworlds-#{version}-osx.dmg"
  name "Teeworlds"
  desc "Retro multiplayer shooter game"
  homepage "https://www.teeworlds.com/"

  livecheck do
    url "https://teeworlds.com/?page=downloads"
    regex(%r{href=.*?/teeworlds[._-](\d+(?:\.\d+)*)[._-]osx\.dmg}i)
  end

  depends_on :macos

  app "Teeworlds.app"
  app "Teeworlds Server.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  caveats do
    requires_rosetta
  end
end
