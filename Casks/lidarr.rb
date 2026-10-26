cask "lidarr" do
  arch arm: "arm64", intel: "x64"

  version "3.1.6.5079"
  sha256 arm:   "6f0a01179dbcf51e87d5569e774b94b60021f4483d30c6281e32eb2ca221b09c",
         intel: "8667bcc4f136237b793432451e35582f2513a9b0bc186af8b81c9692038d2125"

  url "https://github.com/lidarr/Lidarr/releases/download/v#{version}/Lidarr.master.#{version}.osx-app-core-#{arch}.zip"
  name "Lidarr"
  desc "Looks and smells like Sonarr but made for music"
  homepage "https://lidarr.audio/"

  livecheck do
    url "https://lidarr.servarr.com/v1/update/master/changes?os=osx&arch=#{arch}"
    strategy :json do |json|
      json.map { |item| item["version"] }
    end
  end

  auto_updates true
  depends_on :macos

  app "Lidarr.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Lidarr.app"],
        must_succeed: false
  end

  zap trash: "~/.config/Lidarr"
end
