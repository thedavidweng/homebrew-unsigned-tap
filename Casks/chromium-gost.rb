cask "chromium-gost" do
  arch arm: "arm64", intel: "amd64"

  version "156.0.8078.96"
  sha256 arm:   "7c69c7001fc64fd4a4f2896c600f54500a44a9f4102af2cd6e8db333b89abcbc",
         intel: "c149f83f94d41af277bbbb30becee01ecbddf0260a65436fbef9e29e738df5eb"

  url "https://github.com/deemru/Chromium-Gost/releases/download/#{version}/chromium-gost-#{version}-macos-#{arch}.tar.bz2"
  name "Chromium-Gost"
  desc "Browser based on Chromium with support for GOST cryptographic algorithms"
  homepage "https://github.com/deemru/Chromium-Gost"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Chromium-Gost.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Chromium-Gost.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/Chromium",
    "~/Library/Caches/Chromium",
    "~/Library/Preferences/ru.cryptopro.chromium-gost.plist",
  ]
end
