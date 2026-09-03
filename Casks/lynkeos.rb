cask "lynkeos" do
  version "3.10"
  sha256 "18b37ebcf2ebcb08875e2ce55680050b661122147d5ffa15d7090660b1714394"

  url "https://downloads.sourceforge.net/lynkeos/lynkeos/#{version}/Lynkeos-App-#{version.dots_to_hyphens}.zip"
  name "Lynkeos"
  desc "Astronomical webcam image processing software"
  homepage "https://lynkeos.sourceforge.io/"

  livecheck do
    url "https://sourceforge.net/projects/lynkeos/rss?path=/lynkeos"
    regex(%r{url=.*?/v?(\d+(?:\.\d+)+)/Lynkeos[._-]App[\d._-]*\.zip}i)
  end

  depends_on :macos

  app "Lynkeos-App-#{version.dots_to_hyphens}/Lynkeos.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/net.sourceforge.lynkeos.sfl*",
    "~/Library/Caches/com.apple.helpd/Generated/Lynkeos help*",
    "~/Library/Preferences/net.sourceforge.lynkeos.plist",
    "~/Library/Saved Application State/net.sourceforge.lynkeos.savedState",
  ]
end
