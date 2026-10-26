cask "sparkle" do
  version "2.10.1"
  sha256 "1a856d2a9edb8e628de88121d7be04cf0e2167f8641650b78fca00b14244cf27"

  url "https://github.com/sparkle-project/Sparkle/releases/download/#{version}/Sparkle-#{version}.tar.xz"
  name "Sparkle"
  desc "Software update framework for Cocoa developers"
  homepage "https://sparkle-project.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "Sparkle Test App.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Sparkle Test App.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Scripts/org.sparkle-project.Downloader",
    "~/Library/Application Scripts/org.sparkle-project.SparkleTestApp",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/org.sparkle-project.sparkletestapp.sfl*",
    "~/Library/Containers/org.sparkle-project.Downloader",
    "~/Library/Containers/org.sparkle-project.SparkleTestApp",
    "~/Library/Preferences/org.sparkle-project.SparkleTestApp.plist",
  ]
end
