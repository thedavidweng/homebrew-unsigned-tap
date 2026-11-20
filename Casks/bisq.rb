cask "bisq" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.10.12"
  sha256 arm:   "9db7885ee18f651b697e5a4e8c101f73a71b55d30957dd8476885e25dd84e61f",
         intel: "8ba1c24f398d97bbcf09f7ff3ff3d4540c41becb265e0268ed7671a1e0d79213"

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
