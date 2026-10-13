cask "makemkv" do
  version "2.0.0"
  sha256 "e3adad095fb9344e23870d99fd9770a187816332c5a2aa1b226c0bd4a922867a"

  url "https://www.makemkv.com/download/makemkv_v#{version}_osx.dmg"
  name "MakeMKV"
  desc "Video format converter (transcoder)"
  homepage "https://www.makemkv.com/"

  livecheck do
    url "https://www.makemkv.com/download/"
    regex(%r{href=.*?/makemkv[._-]v?(\d+(?:\.\d+)+)[._-]osx\.dmg}i)
  end

  depends_on :macos

  app "MakeMKV.app"
  binary "#{appdir}/MakeMKV.app/Contents/MacOS/makemkvcon"
  binary "#{appdir}/MakeMKV.app/Contents/MacOS/mmccextr"
  binary "#{appdir}/MakeMKV.app/Contents/MacOS/mmgplsrv"
  binary "#{appdir}/MakeMKV.app/Contents/MacOS/sdftool"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/MakeMKV.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/MakeMKV",
    "~/Library/Preferences/com.makemkv.MakeMKV.plist",
    "~/Library/Saved Application State/com.makemkv.MakeMKV.savedState",
    "~/Movies/.MakeMKV",
  ]
end
