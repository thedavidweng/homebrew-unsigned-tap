cask "brewtarget" do
  on_sequoia :or_older do
    version "5.1.1"
    sha256 "01366cec23ca735cb11aec389d4fec61db921e3130ef4f50ee0ceaf9f66313e4"

    livecheck do
      skip "Legacy version for macOS Sequoia"
    end

    depends_on macos: :sequoia
  end
  on_tahoe :or_newer do
    version "5.2.0"
    sha256 "6c954f2809587cbbca53b2f2b6ffdbf2e2e0fa90a4fbaa32b490f8871f0522d1"

    depends_on macos: :tahoe
  end

  url "https://github.com/Brewtarget/brewtarget/releases/download/v#{version}/brewtarget_#{version}_MacOS.dmg"
  name "brewtarget"
  desc "Beer recipe creation tool"
  homepage "https://www.brewtarget.beer/"

  depends_on arch: :arm64
  depends_on :macos

  app "brewtarget_#{version}_MacOS.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/brewtarget_#{version}_MacOS.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/brewtarget",
    "~/Library/Preferences/com.brewtarget.Brewtarget.plist",
    "~/Library/Saved Application State/com.brewtarget.Brewtarget.savedState",
  ]
end
