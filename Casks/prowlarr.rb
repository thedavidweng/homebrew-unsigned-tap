cask "prowlarr" do
  arch arm: "arm64", intel: "x64"

  version "2.7.0.5723"
  sha256 arm:   "3a18a525f20be3431c6abbf0fa220b18a0f02b0a4fd577cdb982d7dc6fe3cf3e",
         intel: "d9aa15f2f55c79bbb928438ac543cef2110729c23468a661cdb7d11edf8a87ae"

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
