cask "circuitjs1" do
  # NOTE: "1" is not a version number, but an intrinsic part of the product name
  arch arm: "arm"

  version "4.1.4js"
  sha256 :no_check

  url "https://www.falstad.com/circuit/offline/CircuitJS1-mac#{arch}.dmg"
  name "Falstad CircuitJS"
  desc "Electronic circuit simulator"
  homepage "https://www.falstad.com/circuit/"

  livecheck do
    url :url
    strategy :extract_plist
  end


  depends_on :macos

  app "CircuitJS1.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Preferences/com.falstad.CircuitJS1.plist",
    "~/Library/Saved Application State/com.falstad.CircuitJS1.savedState",
  ]
end
