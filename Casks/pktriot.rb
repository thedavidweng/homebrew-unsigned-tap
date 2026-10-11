cask "pktriot" do
  arch arm: "arm64", intel: "intel"

  version "1.2.1"
  sha256 arm:   "345d91f4318da142d064103e55e78f6b1bff7ab5239351bcf5b109a843332468",
         intel: "d89eea2c3ce2ea025ba059e84c2086399ad80695da013b836db56cbeae3e9207"

  url "https://download.packetriot.com/macos/pktriot-#{version}.macos.#{arch}.zip"
  name "pktriot"
  desc "Host server applications and static websites"
  homepage "https://packetriot.com/"

  livecheck do
    url "https://packetriot.com/downloads"
    regex(/href=.*?pktriot[._-](\d+(?:\.\d+)+)[._-]macos[._-]?#{arch}\.(?:t|zip)/i)
  end

  depends_on :macos

  binary "pktriot-#{version}/pktriot"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: "~/.pktriot"
end
