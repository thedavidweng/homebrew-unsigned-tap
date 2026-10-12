cask "darktable@intel" do
  version "5.6.1"
  sha256 "ab09e11d548a7028f7bacc2bc4549a272c4e8d385be0e38ecc9e7943914abe61"

  url "https://github.com/darktable-org/darktable/releases/download/release-#{version.major_minor_patch}/darktable-#{version}-x86_64.dmg"
  name "darktable"
  desc "Photography workflow application and raw developer"
  homepage "https://www.darktable.org/"

  livecheck do
    skip "Legacy Intel version; upstream no longer publishes Intel macOS binaries"
  end

  conflicts_with cask: "darktable"
  depends_on arch: :x86_64
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
