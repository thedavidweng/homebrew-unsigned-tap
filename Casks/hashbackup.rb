cask "hashbackup" do
  version "3336"
  sha256 :no_check

  url "https://www.hashbackup.com/download/hb-mac-64bit.tar.gz"
  name "HashBackup"
  desc "Command-line backup program"
  homepage "https://www.hashbackup.com/hashbackup/"

  livecheck do
    url "https://www.hashbackup.com/hashbackup/releases.html"
    regex(/id=["']?_?(\d+)/i)
  end


  depends_on :macos

  binary "hb"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/hashbackup"

  caveats do
    requires_rosetta
  end
end
