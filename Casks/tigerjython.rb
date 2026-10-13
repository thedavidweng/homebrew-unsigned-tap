cask "tigerjython" do
  version "2.43"
  sha256 :no_check

  url "https://www.tjgroup.ch/download/TigerJython.dmg"
  name "TigerJython"
  desc "Jython-based educational programming environment"
  homepage "https://www.tjgroup.ch/"

  livecheck do
    url "https://www.tjgroup.ch/index.php?site=download"
    regex(/version\s+(\d+(?:\.\d+)+)/i)
  end

  depends_on :macos

  suite "TigerJython"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: "~/Library/Caches/org.aplu.TigerJython-Mac"
end
