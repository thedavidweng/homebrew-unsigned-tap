cask "aria-maestosa" do
  version "1.4.13d"
  sha256 "76d46509e0d7b64168158e724e8867ccf34f20b8ec2cdbbfc8c2073597fb9806"

  url "https://downloads.sourceforge.net/ariamaestosa/AriaMaestosa-osx-64bits-#{version}.zip"
  name "Aria Maestosa"
  desc "Midi sequencer and editor"
  homepage "https://ariamaestosa.github.io/ariamaestosa/docs/index.html"

  livecheck do
    url "https://sourceforge.net/projects/ariamaestosa/rss?path=/ariamaestosa"
    regex(%r{url=.*?/AriaMaestosa[._-]osx[._-]64bits[._-]v?(\d+(?:\.\d+)+[a-z]?)\.zip}i)
  end

  depends_on :macos

  app "Aria Maestosa.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Aria Maestosa",
    "~/Library/Autosave Information/org.AriaMaestosa.plist",
    "~/Library/Preferences/AriaMaestosa",
    "~/Library/Saved Application State/org.AriaMaestosa.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
