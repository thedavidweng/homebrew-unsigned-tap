cask "wireframe-sketcher" do
  arch arm: "arm64", intel: "x86_64"

  version "7.4.3"
  sha256 arm:   "4dc531410467c9ae17844575ddee4b1a54cb0f8a2105b1dc4bbc722ba207aba0",
         intel: "0266034c9c7770541908b35904ad0669fefa87500c56faa009482e97a157e84e"

  url "https://wireframesketcher.com/downloads/studio/dist/WireframeSketcher-#{version}-macosx.#{arch}.zip"
  name "WireframeSketcher"
  desc "Tool for creating wireframes, mockups and prototypes"
  homepage "https://wireframesketcher.com/"

  livecheck do
    url "https://wireframesketcher.com/updates/"
    regex(/Current\s+version\s+is\s+v?(\d+(?:\.\d+)+)/i)
  end


  depends_on macos: :big_sur

  app "WireframeSketcher.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Documents/WireframeSketcher",
    "~/Library/Preferences/com.wireframesketcher.studio.plist",
    "~/Library/Saved Application State/com.wireframesketcher.studio.savedState",
  ]
end
