cask "brisync" do
  version "2.0.1"
  sha256 "3033c98c965917383a9a96bb355d2a760e285444a2f89266814f920b3f7da422"

  url "https://github.com/czarny/Brisync/releases/download/v#{version}/Brisync.zip"
  name "Brisync"
  desc "Utility to automatically control the brightness of external displays"
  homepage "https://github.com/czarny/Brisync/"

  depends_on macos: :big_sur

  app "Brisync.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.brisync.json"
end
