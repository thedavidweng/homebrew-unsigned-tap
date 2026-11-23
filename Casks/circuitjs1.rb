cask "circuitjs1" do
  # NOTE: "1" is not a version number, but an intrinsic part of the product name
  arch arm: "arm", intel: "x86"

  version "5.0.6ts"
  sha256 arm:   "56300943ca2be88fc0d22e8c391be3cf40ed969475bbd723491f251f78f61c55",
         intel: "4d360144a7198e5bda34dcc916bb555e4f407633541839cda36b2887af227b91"

  url "https://www.falstad.com/circuit/offline/CircuitJS1-#{version}-mac#{arch}.dmg"
  name "Falstad CircuitJS"
  desc "Electronic circuit simulator"
  homepage "https://www.falstad.com/circuit/"

  livecheck do
    url "https://www.falstad.com/circuit/offline/"
    regex(/href=.*?CircuitJS1[._-]v?(\d+(?:\.\d+)+[a-z]*)[._-]mac#{arch}\.dmg/i)
  end

  depends_on :macos

  app "CircuitJS1.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/CircuitJS1.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.falstad.CircuitJS1.plist",
    "~/Library/Saved Application State/com.falstad.CircuitJS1.savedState",
  ]
end
