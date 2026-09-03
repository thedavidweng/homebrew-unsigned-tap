cask "gingko" do
  version "2.4.15"
  sha256 "bb1367b0a07a80872be253eda0519ec801e0b96b04d59c5bff3f825cf9e380c4"

  url "https://github.com/gingko/client/releases/download/v#{version}/Gingko-#{version}-mac.zip"
  name "Gingko"
  desc "Word processor that shows structure and content"
  homepage "https://gingkowriter.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Gingko.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/Gingko"

  caveats do
    requires_rosetta
  end
end
