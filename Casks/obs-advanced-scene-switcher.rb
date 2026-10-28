cask "obs-advanced-scene-switcher" do
  version "1.37.0"
  sha256 "1c1004996a422432a7e7358b8953aad08df0a2af0003484fab63a8c6b1120478"

  url "https://github.com/WarmUpTill/SceneSwitcher/releases/download/#{version}/advanced-scene-switcher-#{version}-macos-universal.pkg"
  name "OBS Advanced Scene Switcher"
  desc "Automated scene switcher for OBS Studio"
  homepage "https://obsproject.com/forum/resources/advanced-scene-switcher.395"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on cask: "obs"
  depends_on :macos

  pkg "advanced-scene-switcher-#{version}-macos-universal.pkg"

  uninstall pkgutil: [
              "'com.warmuptill.advanced-scene-switcher'",
              "com.warmuptill.advanced-scene-switcher",
            ],
            delete:  "/Library/Application Support/obs-studio/plugins/advanced-scene-switcher.plugin",
            rmdir:   "/Library/Application Support/obs-studio/plugins"

  zap :not_required
end
