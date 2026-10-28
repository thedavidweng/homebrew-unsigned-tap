cask "modmove" do
  version "1.1.2"
  sha256 "6fd6a9929f0e4c5179275c2fa78443baa779300c53ef91113a651d9bf2b25584"

  url "https://github.com/keith/modmove/releases/download/#{version}/ModMove.zip"
  name "ModMove"
  desc "Utility to move/resize windows using modifiers and the mouse"
  homepage "https://github.com/keith/modmove"

  depends_on :macos

  app "ModMove.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/ModMove.app"],
        must_succeed: false
  end

  zap :not_required
end
