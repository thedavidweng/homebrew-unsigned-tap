cask "openforis-collect" do
  version "4.0.111"
  sha256 "e33c1027e758b5305f98699e3192353e3c3a5707442d6ead9e1cad87e85af395"

  url "https://search.maven.org/remotecontent?filepath=org/openforis/collect/collect-installer/#{version}/collect-installer-#{version}-osx.dmg"
  name "Open Foris Collect"
  desc "Data management for field-based inventories"
  homepage "https://openforis.org/solutions/collect/"

  livecheck do
    url "https://search.maven.org/remotecontent?filepath=org/openforis/collect/collect-installer/maven-metadata.xml"
    regex(%r{<version>v?(\d+(?:\.\d+)+)</version>}i)
  end

  depends_on :macos

  rename "OpenForisCollect-*-osx-installer.app", "OpenForisCollect-osx-installer.app"

  installer script: {
    executable: "#{staged_path}/OpenForisCollect-osx-installer.app/Contents/MacOS/osx-x86_64",
    args:       [
      "--mode", "unattended"
    ],
  }

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
  end

  uninstall quit:   "OpenForisCollect-launcher.app",
            signal: [
              ["TERM", "OpenForisCollect-launcher.app"],
            ],
            script: {
              executable: "~/OpenForis/Collect/uninstall.app/Contents/MacOS/osx-x86_64",
              args:       ["--mode", "unattended"],
            }

  zap trash: "~/OpenForis/Collect"
end
