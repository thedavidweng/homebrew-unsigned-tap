cask "gisto" do
  arch arm: "aarch64", intel: "x64"

  version "2.10.1"
  sha256 arm:   "de4737b77181d5cf0acb03873342cc18f889c50bfd9afab645464b08f685274f",
         intel: "569f3034b5022b2b6f7b61edea33a5fb1b5d7d9773c2a96b1e3d55e0475a3929"

  url "https://github.com/Gisto/Gisto/releases/download/v#{version}/Gisto_#{version}_#{arch}.dmg"
  name "Gisto"
  desc "Snippets management desktop application"
  homepage "https://www.gisto.org/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on :macos

  app "Gisto.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Gisto",
    "~/Library/Caches/com.gistoapp.gisto2",
    "~/Library/Logs/Gisto",
    "~/Library/Preferences/com.gistoapp.gisto2.helper.plist",
    "~/Library/Preferences/com.gistoapp.gisto2.plist",
    "~/Library/Saved Application State/com.gistoapp.gisto2.savedState",
  ]
end
