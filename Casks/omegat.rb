cask "omegat" do
  version "6.0.1"
  sha256 "458cfd1508cfe7e73fc193b800f40c533a3191adddc3336769ee4e44fc50b3ae"

  url "https://downloads.sourceforge.net/omegat/OmegaT%20-%20Standard/OmegaT%20#{version.major_minor_patch}/OmegaT_#{version}_Mac.zip"
  name "OmegaT"
  desc "Translation memory tool"
  homepage "https://omegat.org/"

  livecheck do
    url "https://sourceforge.net/projects/omegat/rss?path=/OmegaT%20-%20Standard"
  end

  conflicts_with cask: "omegat@latest"
  depends_on :macos

  app "OmegaT_#{version}_Mac/OmegaT.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/OmegaT",
    "~/Library/Caches/OmegaT",
    "~/Library/Preferences/OmegaT",
    "~/Library/Saved Application State/org.omegat.OmegaT.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
