cask "circuitjs1" do
  # NOTE: "1" is not a version number, but an intrinsic part of the product name
  arch arm: "arm", intel: "x86"

  version "5.0.5ts"
  sha256 arm:   "f145a0b41b3e9f2959c6efea825056930bec58a75d05b25cc911ddb6634456f9",
         intel: "23643a1001e941fd518014bb55a499e3101ca4fb787892a5c79fe18cee627adb"

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
