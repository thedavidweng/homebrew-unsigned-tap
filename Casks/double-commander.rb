cask "double-commander" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.2.11"
  sha256 arm:   "5fd85c49a968c2fa23bf77561035aaed87924a569cad290dbb278fe483392c3f",
         intel: "3cd3b08cba8f520538dfd7493efbc632de72b5909327eaaafbc1648bf111e961"

  url "https://github.com/doublecmd/doublecmd/releases/download/v#{version}/doublecmd-#{version}.cocoa.#{arch}.dmg"
  name "Double Commander"
  desc "File manager with two panels"
  homepage "https://doublecmd.sourceforge.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Double Commander.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Double Commander.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Caches/doublecmd"
end
