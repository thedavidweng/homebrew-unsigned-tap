cask "prowlarr" do
  arch arm: "arm64", intel: "x64"

  version "2.5.2.5491"
  sha256 arm:   "c6233cd942aad3c382c2660ad0004f942a3cd54c4fb8b805e14d2cd1d6b2b264",
         intel: "c6e5074b431259f4ddbf26aba35e618a920154ccb9a342bbc072e0f817c8331d"

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
  depends_on macos: :big_sur

  app "Prowlarr.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.config/Prowlarr"
end
