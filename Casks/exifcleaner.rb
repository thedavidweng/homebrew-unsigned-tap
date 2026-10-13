cask "exifcleaner" do
  arch arm: "-arm64"

  version "4.5.0"
  sha256 arm:   "e340c4761caf0eacf4931b6272281b3a3a46ee6f6af5cc8a2af84bd136f861d9",
         intel: "dd569c0f7ad7bddfdee0c4f00974bde96f06b87a54c02ccde17c8222c538501b"

  url "https://github.com/szTheory/exifcleaner/releases/download/v#{version}/ExifCleaner-#{version}#{arch}.dmg"
  name "ExifCleaner"
  desc "Metadata cleaner"
  homepage "https://exifcleaner.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "ExifCleaner.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/ExifCleaner.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.exifcleaner.sfl*",
    "~/Library/Application Support/ExifCleaner",
    "~/Library/Preferences/com.exifcleaner.plist",
    "~/Library/Saved Application State/com.exifcleaner.savedState",
  ]
end
