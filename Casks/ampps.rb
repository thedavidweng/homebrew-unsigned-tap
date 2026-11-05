cask "ampps" do
  version "4.5"
  sha256 "df6543323f0b40657046f0fadbc4418c6fbc8ce8e0a030a0b68b2b5fd765f99a"

  url "https://s1.softaculous.com/a/ampps/files/versions/AMPPS-#{version}-x86_64.dmg"
  name "AMPPS"
  desc "Software stack for website development"
  homepage "https://www.ampps.com/"

  livecheck do
    url "https://api.ampps.com/download.php?arch=mac64"
    regex(/AMPPS[._-]v?(\d+(?:\.\d+)+)-x86_64\.dmg/i)
    strategy :header_match
  end

  depends_on :macos

  suite "AMPPS"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  uninstall_preflight_steps do
    set_permissions "AMPPS", "0777", base: :appdir
  end

  caveats do
    requires_rosetta
  end
end
