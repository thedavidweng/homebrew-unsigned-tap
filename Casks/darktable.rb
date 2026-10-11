cask "darktable" do
  version "5.6.2"
  sha256 "6ff88e58a2a59cb07b0a1502fea7205e68cd783380a33a3ce7bda68ec29def0c"

  url "https://github.com/darktable-org/darktable/releases/download/release-#{version.major_minor_patch}/darktable-#{version}-arm64.dmg"
  name "darktable"
  desc "Photography workflow application and raw developer"
  homepage "https://www.darktable.org/"

  livecheck do
    url "https://www.darktable.org/install/"
    regex(/href=.*?darktable[._-]v?(\d+(?:\.\d+)+)[._-]arm64\.dmg/i)
  end

  conflicts_with cask: "darktable@intel"
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "darktable.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/darktable.app"],
        must_succeed: false
  end

  uninstall quit: "org.darktable"

  zap trash: [
    "~/.cache/darktable",
    "~/.config/darktable",
    "~/.local/share/darktable",
    "~/Library/Saved Application State/org.darktable.savedState",
  ]
end
