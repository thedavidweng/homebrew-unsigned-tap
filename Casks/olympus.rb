cask "olympus" do
  version "5939"
  sha256 "08891eb42added3a5ef62daadaa3150eb72debaf366f241bc2d9285cbf7ceb41"

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

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Olympus.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Olympus",
    "~/Library/Saved Application State/everest.olympus.savedState",
  ]
end
