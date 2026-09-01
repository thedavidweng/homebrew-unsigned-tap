cask "radarr" do
  arch arm: "arm64", intel: "x64"

  version "6.2.1.10461"
  sha256 arm:   "bdb5d89c9c83efe55cdfc9abed9bc256a8f1a88ba847f670db6121a6acc4504e",
         intel: "b322bde15d9920aa49aead642fb1f1bdad8b8a4f7f143f185833478ee1b18185"

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
  depends_on macos: :big_sur

  app "Radarr.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.config/Radarr"
end
