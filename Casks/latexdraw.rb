cask "latexdraw" do
  version "4.0.3"
  sha256 "7a21014c60d1d75fc8efe8c0d3ba8e827d2d09d29daeda492aff5d7cbc4f257c"

  url "https://downloads.sourceforge.net/latexdraw/LaTeXDraw-#{version}.dmg"
  name "LaTexDraw"
  desc "Drawing editor for creating LaTeX PSTricks code"
  homepage "https://latexdraw.sourceforge.net/"

  livecheck do
    url "https://sourceforge.net/projects/latexdraw/rss?path=/latexdraw"
    regex(%r{url=.*?/LaTeXDraw[._-]v?(\d+(?:\.\d+)+)\.dmg}i)
  end


  depends_on :macos

  app "LaTeXDraw.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/.latexdraw",
    "~/Library/Preferences/latexdraw.plist",
    "~/Library/Saved Application State/latexdraw.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
