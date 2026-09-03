cask "nulloy" do
  version "0.9.9"
  sha256 "44f9c74fe1ea924db3aeb2f7e087e0391a2fd96ea871bb9c9f9fea529f10c3db"

  url "https://github.com/nulloy/nulloy/releases/download/#{version}/Nulloy-#{version}-x86_64.dmg"
  name "Nulloy"
  desc "Music player"
  homepage "https://nulloy.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Nulloy.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Saved Application State/com.nulloy.savedState"
end
