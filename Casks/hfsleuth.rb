cask "hfsleuth" do
  version :latest
  sha256 :no_check

  url "https://newosxbook.com/files/hfsleuth.tar"
  name "HFSleuth"
  desc "HFS+/HFSX file system inspection tool"
  homepage "https://newosxbook.com/tools/hfsleuth.html"

  livecheck do
    skip "unversioned command-line application"
  end


  depends_on :macos

  binary "hfsleuth.universal", target: "hfsleuth"
  manpage "hfsleuth.1"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end
end
