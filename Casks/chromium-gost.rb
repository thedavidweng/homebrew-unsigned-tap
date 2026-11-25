cask "chromium-gost" do
  arch arm: "arm64", intel: "amd64"

  version "156.0.8078.114"
  sha256 arm:   "65a2e1aa319058b33b606285a00d73c468fdc6a8ab6c57ccc1f6072dfc78e80c",
         intel: "f8cac9760c544c767dac24f45282b48a8c4cb2ccf25212966ebbed62b030eb33"

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
