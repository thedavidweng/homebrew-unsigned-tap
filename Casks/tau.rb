cask "tau" do
  arch arm: "_arm64"

  version "2.35.2"
  sha256 :no_check

  url "https://www.cs.uoregon.edu/research/tau/tau#{arch}.dmg"
  name "TAU"
  desc "Profiling and tracing toolkit"
  homepage "https://www.cs.uoregon.edu/research/tau/home.php"

  livecheck do
    url "https://www.cs.uoregon.edu/research/tau/downloads.php"
    regex(/version\s+(\d+(?:\.\d+)+)/i)
  end

  depends_on :macos

  suite "TAU"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  uninstall delete: "#{staged_path}/TAU/tau/"

  zap trash: "~/.ParaProf"

  caveats do
    depends_on_java
  end
end
