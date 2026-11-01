cask "pencil" do
  version "4.0.0"
  sha256 "ae00709acfe02a1d171f87f271d334f12c0dc5d4493086a05ce4998a7eb3388d"

  url "https://pencil.evolus.vn/dl/V#{version}.ga/Pencil-#{version}-universal.dmg"
  name "Pencil"
  name "The Pencil Project"
  desc "GUI prototyping tool"
  homepage "https://pencil.evolus.vn/"

  livecheck do
    url "https://pencil.evolus.vn/Downloads.html"
    regex(/href=.*?Pencil[._-]v?(\d+(?:\.\d+)+)[^"' >]*?\.dmg/i)
  end

  depends_on :macos

  app "Pencil.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Pencil.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.pencil",
    "~/Library/Application Support/Pencil",
    "~/Library/Preferences/vn.evolus.pencil.plist",
  ]
end
