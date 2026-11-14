cask "electron" do
  arch arm: "arm64", intel: "x64"

  version "45.3.3"
  sha256 arm:   "25ae0ce40ee462433c1029b8fcc485949fc8a89394b62b70887d7793898edc89",
         intel: "151d249b646eb8b99f1bea40aff217b10d8e21246ad8c07bb3a5982e2722660f"

  url "https://github.com/electron/electron/releases/download/v#{version}/electron-v#{version}-darwin-#{arch}.zip"
  name "Electron"
  desc "Build desktop apps with JavaScript, HTML, and CSS"
  homepage "https://electronjs.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Electron.app"
  binary "#{appdir}/Electron.app/Contents/MacOS/Electron", target: "electron"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Electron.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.github.electron.sfl*",
    "~/Library/Application Support/Electron",
    "~/Library/Caches/Electron",
    "~/Library/Preferences/com.github.electron.helper.plist",
    "~/Library/Preferences/com.github.electron.plist",
    "~/Library/Saved Application State/com.github.Electron.savedState",
  ]
end
