cask "texstudio" do
  arch arm: "-m1"

  version "4.9.8"
  sha256 arm:   "e66fd2a6305e88ac88d47deee3306f449d29b1f3a8e49f382fcaea2a79f29373",
         intel: "8c87cc80cd56af21663b3c7d9b411440e573d108724c01dce0d0e8c6db61dabc"

  url "https://github.com/texstudio-org/texstudio/releases/download/#{version}/texstudio-#{version}-osx#{arch}.zip"
  name "TeXstudio"
  desc "LaTeX editor"
  homepage "https://texstudio.org/"

  depends_on macos: :ventura

  app "texstudio-#{version}-osx#{arch}.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/texstudio-#{version}-osx#{arch}.app"],
        must_succeed: false
  end

  uninstall quit: "texstudio"

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/texstudio.sfl*",
    "~/Library/Preferences/texstudio.plist",
    "~/Library/Saved Application State/texstudio.savedState",
  ]
end
