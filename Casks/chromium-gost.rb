cask "chromium-gost" do
  arch arm: "arm64", intel: "amd64"

  version "156.0.8078.79"
  sha256 arm:   "fe024cf0c38d8ba62963d4bf7afa6e26a42de141f4090b4adbe8840ed962d71e",
         intel: "4830b26fdc7e5a03e9a3dce1c9569515b60b90c3396d5b89b2021599c185252c"

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
