cask "pixelorama" do
  version "1.1.10"
  sha256 "c647b3d24532ffc8fb12367a123773feeba321399a87e458ffc3cc78f30bbf81"

  url "https://github.com/Orama-Interactive/Pixelorama/releases/download/v#{version}/Pixelorama-Mac.dmg"
  name "Pixelorama"
  desc "2D sprite editor made with the Godot Engine"
  homepage "https://orama-interactive.itch.io/pixelorama"


  depends_on macos: :big_sur

  app "Pixelorama.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Saved Application State/com.orama_interactive.pixelorama.savedState"
end
