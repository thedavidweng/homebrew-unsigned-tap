cask "pyfa" do
  arch arm: "arm64", intel: "x86_64"

  version "2.69.2"
  sha256 arm:   "a6c669ff75b7ec2c09616fe408ecec65938c2392e4235a9adb021bf3224507bf",
         intel: "768c0f48e9218b917cac5a0ed3c37c47eae6cdfb724b7dfd902755134fe11ce7"

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
