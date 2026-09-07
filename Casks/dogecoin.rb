cask "dogecoin" do
  version "1.14.9"
  sha256 "c87c956834a87da8200274a097364c986ccca045d71ce92d0f7d407129d25a83"

  url "https://github.com/dogecoin/dogecoin/releases/download/v#{version}/dogecoin-#{version}-osx-unsigned.dmg"
  name "Dogecoin"
  desc "Cryptocurrency"
  homepage "https://dogecoin.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Dogecoin-Qt.app"

  preflight_steps do
    set_permissions "Dogecoin-Qt.app", "0755"
  end

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  zap trash: "~/Library/com.dogecoin.Dogecoin-Qt.plist"

  caveats do
    requires_rosetta
  end
end
