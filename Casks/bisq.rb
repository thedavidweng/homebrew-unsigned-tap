cask "bisq" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.10.9"
  sha256 arm:   "1cc8cd95ad5dfbf0bf321cf560de9d47bfb0e820b051e8d2b590d839d40537cb",
         intel: "8617bccbe087a28c75b43f603494d1e3c7fca1443190de477048f8702c279492"

  url "https://github.com/bisq-network/bisq/releases/download/v#{version}/Bisq-#{arch}-#{version}.dmg"
  name "Bisq"
  desc "Decentralised bitcoin exchange network"
  homepage "https://bisq.network/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Bisq.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Bisq.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Bisq",
    "~/Library/Saved Application State/io.bisq.CAT.savedState",
  ]
end
