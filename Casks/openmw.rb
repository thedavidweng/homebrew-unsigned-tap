cask "openmw" do
  arch arm: "arm64", intel: "x86_64"

  version "0.51.0"
  sha256 arm:   "76bc0436413ed500dcd846a2cc3889711af948645bdd4eafd36ad16bc0c5615c",
         intel: "cce014e1827cf2b1a23017894015648298c90e3324097fac157dd9e40b341602"

  on_arm do
    depends_on macos: :sonoma
  end
  on_intel do
    depends_on macos: :ventura
  end

  url "https://github.com/OpenMW/openmw/releases/download/openmw-#{version}/OpenMW-#{version}-macOS-#{arch}.dmg"
  name "OpenMW"
  desc "Open-source open-world RPG game engine that supports playing Morrowind"
  homepage "https://openmw.org/"

  livecheck do
    url :url
    regex(/openmw[._-]v?(\d+(?:\.\d+)+)/i)
    strategy :github_latest
  end

  depends_on :macos

  app "OpenMW.app"
  app "OpenMW-CS.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/openmw",
    "~/Library/Preferences/openmw",
    "~/Library/Preferences/org.openmw.openmw.plist",
    "~/Library/Saved Application State/org.openmw.*.savedState",
  ]
end
