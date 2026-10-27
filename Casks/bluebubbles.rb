cask "bluebubbles" do
  arch arm: "-arm64"

  version "1.9.11"
  sha256 arm:   "4e2850b1db5f7e2a02cee7f0bf8f9b402c0e26b8b208ec3425bae8a9b0f05ffd",
         intel: "ac9839367489bac895b905fe4318dee4704de99c8859dfaadb801a05e3382922"

  url "https://github.com/BlueBubblesApp/bluebubbles-server/releases/download/v#{version}/BlueBubbles-#{version}#{arch}.dmg"
  name "BlueBubbles"
  desc "Server for forwarding iMessages"
  homepage "https://bluebubbles.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "BlueBubbles.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/BlueBubbles.app"],
        must_succeed: false
  end

  uninstall launchctl:  "com.BlueBubbles.BlueBubbles-Server.ShipIt",
            quit:       [
              "com.BlueBubbles.BlueBubbles-Server",
              "com.BlueBubbles.BlueBubbles-Server.helper",
              "com.BlueBubbles.BlueBubbles-Server.helper.GPU",
              "com.BlueBubbles.BlueBubbles-Server.helper.Plugin",
              "com.BlueBubbles.BlueBubbles-Server.helper.Renderer",
              "com.bluebubbles.messaging",
            ],
            login_item: "BlueBubbles"

  zap trash: [
    "~/Library/Application Support/@bluebubbles",
    "~/Library/Application Support/bluebubbles-server",
    "~/Library/Logs/@bluebubbles",
    "~/Library/Logs/bluebubbles-server",
    "~/Library/Preferences/com.BlueBubbles.BlueBubbles-Server.plist",
    "~/Library/Saved Application State/com.BlueBubbles.BlueBubbles-Server.savedState",
  ]
end
