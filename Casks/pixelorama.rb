cask "pixelorama" do
  version "1.2.1"
  sha256 "0999c2652473ae0688fa1d53de3863059b6d17ed1588a9a6aaf5b22c6c4ccf27"

  url "https://github.com/Orama-Interactive/Pixelorama/releases/download/v#{version}/Pixelorama-Mac.dmg"
  name "Pixelorama"
  desc "2D sprite editor made with the Godot Engine"
  homepage "https://orama-interactive.itch.io/pixelorama"


  depends_on macos: :big_sur

  app "Pixelorama.app"

  uninstall quit: "com.orama-interactive.pixelorama"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Saved Application State/com.orama_interactive.pixelorama.savedState"
end
