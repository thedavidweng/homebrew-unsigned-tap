cask "pyfa" do
  arch arm: "arm64", intel: "x86_64"

  version "2.70.1"
  sha256 arm:   "7a73f724a31b92cd2362fa254ad12816cf52d81c4c123e0c9d02dfff399d6a4c",
         intel: "714efea043976e413544144f7e0c7443d7457dce4ac01649fff4b8c94982cc0c"

  url "https://github.com/pyfa-org/Pyfa/releases/download/v#{version}/pyfa-v#{version}-mac-#{arch}.zip"
  name "pyfa"
  desc "Fitting tool for EVE Online"
  homepage "https://github.com/pyfa-org/Pyfa"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "pyfa.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/pyfa.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Caches/org.pyfaorg.pyfa",
    "~/Library/Preferences/org.pyfaorg.pyfa.plist",
    "~/Library/Saved Application State/org.pyfaorg.pyfa.savedState",
  ]
end
