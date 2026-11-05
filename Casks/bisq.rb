cask "bisq" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.10.11"
  sha256 arm:   "35a21a1e82465299e7126d3b8f54c012d728e11f58c996ccaef99a7a6f943b36",
         intel: "67490a83c1ecc12a2b73420ae6edf8763b66562aa62d07f8df7ff406c9cb8a35"

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
