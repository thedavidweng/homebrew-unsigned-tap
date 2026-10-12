cask "leocad" do
  version "26.09"
  sha256 "ff11940f01ed171165927dbe69c3e38fe04a8a7127c7176fd25e7e76303cae97"

  url "https://github.com/leozide/leocad/releases/download/v#{version}/LeoCAD-macOS-#{version}.dmg"
  name "LeoCAD"
  desc "CAD program for creating virtual LEGO models"
  homepage "https://github.com/leozide/leocad"

  depends_on :macos

  app "LeoCAD.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/LeoCAD.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Caches/LeoCAD Software",
    "~/Library/Preferences/org.leocad.LeoCAD.plist",
    "~/Library/Saved Application State/org.leozide.LeoCAD.savedState",
  ]
end
