cask "prowlarr" do
  arch arm: "arm64", intel: "x64"

  version "2.4.0.5397"
  sha256 arm:   "1ea353c59826c1442d6f0f89315f2807d04f296c23fe7f0688818c15e1352859",
         intel: "2298a5cd2a42c0b91ef90e3a88388afc6f4f704c394498985545553cda1474b1"

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
