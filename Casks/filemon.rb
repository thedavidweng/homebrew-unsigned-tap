cask "filemon" do
  version "2.0"
  sha256 :no_check

  url "https://newosxbook.com/tools/filemon.tgz"
  name "File Monitor"
  desc "FSEvents client"
  homepage "https://newosxbook.com/tools/filemon.html"

  livecheck do
    url :homepage
    regex(/File\s*Monitor\s+(\d+(?:\.\d+)+)/i)
  end

  depends_on :macos

  binary "filemon"

  # No zap stanza required

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end
end
