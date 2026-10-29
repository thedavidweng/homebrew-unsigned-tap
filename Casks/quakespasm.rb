cask "quakespasm" do
  version "0.97.0"
  sha256 "5115a98ed41f99cc21a1769df942d9cc03665c1d4c2f631785adfdd94a731c17"

  url "https://downloads.sourceforge.net/quakespasm/Mac/QuakeSpasm-#{version}-osx-SDL2.zip"
  name "QuakeSpasm"
  desc "Engine for iD software's Quake"
  homepage "https://quakespasm.sourceforge.net/"

  livecheck do
    url "https://sourceforge.net/projects/quakespasm/rss?path=/Mac"
  end

  depends_on :macos

  suite "QuakeSpasm"

  preflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{staged_path}}"]
    # There is no sub-folder; the root *is* the folder
    move_contents ".", "QuakeSpasm"
  end

  caveats <<~EOS
    To complete the installation of #{token}, you will have to copy the files
    'pak0.pak' and 'pak1.pak' from your Quake 1 installation support directory
    into #{appdir}/QuakeSpasm/id1/
  EOS
end
