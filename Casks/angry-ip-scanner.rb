cask "angry-ip-scanner" do
  arch arm: "Arm64", intel: "X86"

  version "3.10.0"
  sha256 arm:   "4047730a0dd8f8617bdc876d72b55b54b16ad4243c05793cb85bed9c945ec885",
         intel: "0917fdca45ac90d786f3b927275f9a797c089580e3b12218ebd53edfe9e061ae"

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
