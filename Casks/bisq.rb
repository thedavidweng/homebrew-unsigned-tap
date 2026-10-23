cask "bisq" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.10.10"
  sha256 arm:   "b66b05ac52c07200c6d7537a188d52980a871b0a2fde7e74f8b6a9d9bbb1ea79",
         intel: "6750e5edf0b6b84160a84ec2ecea6dcc6959cd8e753f337a7f1d6969ffb18ffc"

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
