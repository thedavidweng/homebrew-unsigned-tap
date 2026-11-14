cask "olympus" do
  version "6000"
  sha256 "08db52daf13ac8769655700adca0ea2d4ebb0e11560bd243db197b7946c40123"

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
