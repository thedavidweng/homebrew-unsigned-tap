cask "chromium-gost" do
  arch arm: "arm64", intel: "amd64"

  version "156.0.8078.108"
  sha256 arm:   "4932e1e79ac8c63638a668b5f5886259e607addd0ee95bbdb7ff0d7da9c5a742",
         intel: "8458f899e09df2e8c32c75087647b0c3e2ff89a19532b8b7284c9e6676fc9776"

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
