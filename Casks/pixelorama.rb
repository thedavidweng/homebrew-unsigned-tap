cask "pixelorama" do
  version "1.2.3"
  sha256 "f007d9d84a8410d568f173493055782dfadfd00772e6ea08cc087e3ae08629c5"

  url "https://github.com/Orama-Interactive/Pixelorama/releases/download/v#{version}/Pixelorama-Mac.dmg"
  name "Pixelorama"
  desc "2D sprite editor made with the Godot Engine"
  homepage "https://orama-interactive.itch.io/pixelorama"

  depends_on :macos

  app "Pixelorama.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Pixelorama.app"],
        must_succeed: false
  end

  uninstall quit: "com.orama-interactive.pixelorama"

  zap trash: "~/Library/Saved Application State/com.orama_interactive.pixelorama.savedState"
end
