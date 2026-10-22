cask "archy" do
  version "2.44.0"
  sha256 "8e8b31263c12163903b54a1f90a814631d251551c96959e2351e5adb8eb89505"

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
