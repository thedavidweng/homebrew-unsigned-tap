cask "keyboardholder" do
  version "1.14.10"
  sha256 "4a436c1a1064905f74b7587c716e19b391df06d668e363ba7b1033ea2ea3752a"

  url "https://github.com/leaves615/KeyboardHolder/releases/download/v#{version}/KeyboardHolder-#{version}.zip"
  name "KeyboardHolder"
  desc "Switch input method per application"
  homepage "https://keyboardholder.leavesc.com/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on macos: :big_sur

  app "KeyboardHolder.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
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
