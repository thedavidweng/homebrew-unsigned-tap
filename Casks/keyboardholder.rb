cask "keyboardholder" do
  version "1.14.16"
  sha256 "42d0f8d93a8073ffe3094d2508d771a72454907da5d982beba85c9bbed9db05d"

  url "https://github.com/leaves615/KeyboardHolder/releases/download/v#{version}/KeyboardHolder-#{version}.zip"
  name "KeyboardHolder"
  desc "Switch input method per application"
  homepage "https://keyboardholder.leavesc.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "KeyboardHolder.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/KeyboardHolder.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Scripts/cn.leaves.KeyboardHolderLaunchHelper",
    "~/Library/Application Support/cn.leaves.KeyboardHolder",
    "~/Library/Caches/cn.leaves.KeyboardHolder",
    "~/Library/Caches/com.plausiblelabs.crashreporter.data/cn.leaves.KeyboardHolder",
    "~/Library/Containers/cn.leaves.KeyboardHolderLaunchHelper",
    "~/Library/Logs/cn.leaves.KeyboardHolder",
    "~/Library/Preferences/cn.leaves.KeyboardHolder.plist",
  ]
end
