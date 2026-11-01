cask "double-commander" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.2.10"
  sha256 arm:   "890bf553059d82150b185c0cb7a71ba0de55350d66a0329d941acafb21452470",
         intel: "58ff7ed995bed778599bb242aa0f6a922262b1f6269521a4492329557de8f967"

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
