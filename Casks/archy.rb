cask "archy" do
  version "2.44.2"
  sha256 "85335dbd817cb11d440df0599413373d680daa813605b2c59a5c069a86124e1d"

  url "https://sdk-cdn.mypurecloud.com/archy/#{version}/archy-macos.zip"
  name "Archy"
  desc "YAML processor"
  homepage "https://developer.genesys.cloud/devapps/archy/"

  livecheck do
    url "https://sdk-cdn.mypurecloud.com/archy/versions.json"
    strategy :json do |json|
      json.map { |item| item["version"] }
    end
  end

  depends_on :macos

  binary "archyBin/archy-macos-#{version}", target: "archy"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: "~/.archy_config"

  caveats do
    requires_rosetta
  end
end
