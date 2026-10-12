cask "prowlarr" do
  arch arm: "arm64", intel: "x64"

  version "2.6.5.5623"
  sha256 arm:   "cd3401b34a11256fcb5e49c26e20382ca4d3f14c1d2c102247a4a46e66a5ab24",
         intel: "7055b1e585767888643027d20c9347982a720b8b6f2067a8ae81ed08f5f266d9"

  url "https://github.com/Prowlarr/Prowlarr/releases/download/v#{version}/Prowlarr.master.#{version}.osx-app-core-#{arch}.zip"
  name "Prowlarr"
  desc "Indexer manager/proxy for various PVR apps"
  homepage "https://prowlarr.com/"

  livecheck do
    url "https://prowlarr.servarr.com/v1/update/master/changes?os=osx&arch=#{arch}"
    strategy :json do |json|
      json.map { |item| item["version"] }
    end
  end

  auto_updates true
  depends_on :macos

  app "Prowlarr.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Prowlarr.app"],
        must_succeed: false
  end

  zap trash: "~/.config/Prowlarr"
end
