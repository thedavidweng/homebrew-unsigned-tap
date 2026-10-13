cask "archy" do
  version "2.43.2"
  sha256 "dfd4338ccebe58e2c7490e6ea660eb36727f59cb5473d869074fda434d825c55"

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
