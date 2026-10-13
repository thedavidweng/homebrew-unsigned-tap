cask "wireframe-sketcher" do
  arch arm: "arm64", intel: "x86_64"

  version "7.4.4"
  sha256 arm:   "c8e73d7bbc176b8ac89a83686e172c4bf35a7d016259ca2265efe112d0c631eb",
         intel: "02f084adb708fcbd6ac02286e37c09d12e4ffedf13d536fa6a37cdf2ea14eac1"

  url "https://wireframesketcher.com/downloads/studio/dist/WireframeSketcher-#{version}-macosx.#{arch}.zip"
  name "WireframeSketcher"
  desc "Tool for creating wireframes, mockups and prototypes"
  homepage "https://wireframesketcher.com/"

  livecheck do
    url "https://wireframesketcher.com/updates/"
    regex(/Current\s+version\s+is\s+v?(\d+(?:\.\d+)+)/i)
  end

  depends_on :macos

  app "WireframeSketcher.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/WireframeSketcher.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Documents/WireframeSketcher",
    "~/Library/Preferences/com.wireframesketcher.studio.plist",
    "~/Library/Saved Application State/com.wireframesketcher.studio.savedState",
  ]
end
