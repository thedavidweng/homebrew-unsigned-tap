cask "vnote" do
  on_monterey :or_older do
    version "4.5.0"
    sha256 "56cdc30ee70f79fe504e49cdd31b5975083072e3c8c446c6bc04735dfc973ca8"

    livecheck do
      skip "Pinned release for macOS Monterey and older"
    end
  end
  on_ventura :or_newer do
    version "4.14.0"
    sha256 "7d7650be91b7cd2e24857569a6e6efc2cd1d5b43da0e51b83c8145f16be8ee0b"
  end

  url "https://github.com/vnotex/vnote/releases/download/v#{version}/VNote-#{version}-mac-universal.dmg"
  name "VNote"
  desc "Note-taking platform"
  homepage "https://docs.vnote.fun/"

  depends_on macos: :monterey

  app "VNote.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/VNote.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/VNote",
    "~/Library/Preferences/com.vnotex.vnote.plist",
    "~/Library/Preferences/VNote",
  ]
end
