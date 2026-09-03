cask "olympus" do
  version "5722"
  sha256 "9d8b085c2c7aaceb03e802b85c767e94ce8dd5601eeccdd02ad0ed4a2db9bb37"

  url "https://dev.azure.com/EverestAPI/Olympus/_apis/build/builds/#{version}/artifacts?artifactName=macos.main&$format=zip"
  name "Olympus"
  desc "Everest (Mod loader for video games Celeste) installer / manager"
  homepage "https://everestapi.github.io/"

  livecheck do
    url "https://dev.azure.com/EverestAPI/Olympus/_apis/build/builds"
    strategy :json do |json|
      json["value"]&.map do |build|
        build["id"]&.to_s if build["sourceBranch"] == "refs/heads/stable"
      end
    end
  end

  depends_on :macos
  container nested: "macos.main/dist.zip"

  app "Olympus.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/Olympus",
    "~/Library/Saved Application State/everest.olympus.savedState",
  ]
end
