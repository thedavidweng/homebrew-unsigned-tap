cask "chromium-gost" do
  arch arm: "arm64", intel: "amd64"

  version "152.0.7977.149"
  sha256 arm:   "7032abf55d4ac19e0038cc2e70d438ca653e20b7360bc15bf60659044da34fc6",
         intel: "a4e7b409350e8cb9369e1b95e090b5be3aae6645986d894dd355fc275128c51f"

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
