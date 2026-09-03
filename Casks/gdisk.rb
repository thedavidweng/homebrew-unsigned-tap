cask "gdisk" do
  version "1.0.10"
  sha256 "38f0d2947803912cf0861f7a07ed2ae76979c88de5c20d6b10d6f9e7fe72b07d"

  url "https://downloads.sourceforge.net/gptfdisk/gdisk-#{version}.pkg"
  name "GPT fdisk"
  desc "Disk partitioning tool"
  homepage "https://sourceforge.net/projects/gptfdisk/"

  depends_on :macos

  pkg "gdisk-#{version}.pkg"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall pkgutil: "com.rodsbooks.pkg.gdisk"

  # No zap stanza required
end
