cask "opentoonz" do
  version "1.8.0"
  sha256 "6360efbde7739910d4eefe9d494b6b57e852a3f75bdbeb1e6d75abb84e609d13"

  url "https://github.com/opentoonz/opentoonz/releases/download/v#{version}/OpenToonz.pkg"
  name "OpenToonz"
  desc "Open-source full-featured 2D animation creation software"
  homepage "https://opentoonz.github.io/e/index.html"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  pkg "OpenToonz.pkg"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", "{{staged_path}}"]
  end

  uninstall pkgutil: "io.github.opentoonz"

  zap trash: [
    "~/Library/Caches/OpenToonz",
    "~/Library/Saved Application State/io.github.opentoonz.OpenToonz.savedState",
  ]
end
