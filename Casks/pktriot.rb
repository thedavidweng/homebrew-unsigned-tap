cask "pktriot" do
  arch arm: "arm64", intel: "intel"

  version "1.2.2"
  sha256 arm:   "2bea3ed5c2660f0bfe57da68ed39eb370aa2b616775fe46c4aadbe2adbb4dcbb",
         intel: "7f5749b40a361b02dd7836d1691a07bfdeee053d296b670cb2f5deb4f2825a19"

  url "https://download.packetriot.com/macos/pktriot-#{version}.macos.#{arch}.zip"
  name "pktriot"
  desc "Host server applications and static websites"
  homepage "https://packetriot.com/"

  livecheck do
    url "https://packetriot.com/downloads"
    regex(/href=.*?pktriot[._-](\d+(?:\.\d+)+)[._-]macos[._-]?#{arch}\.(?:t|zip)/i)
  end

  depends_on macos: :ventura

  binary "pktriot-#{version}/pktriot"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: "~/.pktriot"
end
