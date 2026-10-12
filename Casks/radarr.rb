cask "radarr" do
  arch arm: "arm64", intel: "x64"

  version "6.4.4.10685"
  sha256 arm:   "fda0e0750717cbde378775f60b25e328a8fb8677f6a070b7c84c5f212827ec8b",
         intel: "9808f0827448aca9a9f82d055d0f25aeee061351326b2d8348b9f7d48f69a646"

  url "https://github.com/Radarr/Radarr/releases/download/v#{version}/Radarr.master.#{version}.osx-app-core-#{arch}.zip"
  name "Radarr"
  desc "Fork of Sonarr to work with movies à la Couchpotato"
  homepage "https://radarr.video/"

  livecheck do
    url "https://radarr.servarr.com/v1/update/master/changes?os=osx&arch=#{arch}"
    strategy :json do |json|
      json.map { |item| item["version"] }
    end
  end

  auto_updates true
  depends_on :macos

  app "Radarr.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Radarr.app"],
        must_succeed: false
  end

  zap trash: "~/.config/Radarr"
end
