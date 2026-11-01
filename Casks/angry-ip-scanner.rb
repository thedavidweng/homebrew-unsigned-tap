cask "angry-ip-scanner" do
  arch arm: "Arm64", intel: "X86"

  version "3.12.0"
  sha256 arm:   "6c740e8eb12730166de1be38f1a1c243b7899f21bc6369d8beb0e47ea88a6b6d",
         intel: "255dc2766873b06921745c02738329b8aa05cdfc3297ac71c15722bf0ff17e9e"

  url "https://github.com/angryip/ipscan/releases/download/#{version}/ipscan-#{version}-mac#{arch}.zip"
  name "Angry IP Scanner"
  desc "Network scanner"
  homepage "https://angryip.org/"

  depends_on :macos

  app "Angry IP Scanner.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Angry IP Scanner.app"],
        must_succeed: false
  end

  zap :not_required
end
