cask "chromium-gost" do
  arch arm: "arm64", intel: "amd64"

  version "156.0.8078.48"
  sha256 arm:   "8cf729718d8c42cd662a3db79cc525687e1c611f57ea1d9e913065c1aeb089fd",
         intel: "8ca707077eaf6cb7b492bf928934a1ec62e76b29be27bf931d5ebcbc4376a55a"

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
