cask "pliim" do
  version "1.7.0"
  sha256 "cd44a3e8d0d58b431df288c3ce13a8032f76b270077ac488cb9db5d74e7d17a5"

  url "https://github.com/zehfernandes/pliim/releases/download/v#{version}/Pliim.app.zip"
  name "Pliim"
  desc "One click and be ready to go up on stage and shine!"
  homepage "https://zehfernandes.github.io/pliim/"

  depends_on :macos

  app "Pliim.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Pliim",
    "~/Library/Logs/Pliim",
    "~/Library/Preferences/com.electron.pliim.plist",
    "~/Library/Saved Application State/com.electron.pliim.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
