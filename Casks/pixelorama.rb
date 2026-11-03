cask "pixelorama" do
  version "1.2.4"
  sha256 "aef909572cb008174e758fbc36998823363e44d9eaffa974b156d4284c549ce7"

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
