cask "sqlpro-studio" do
  version "2026.301.4"
  sha256 "4fa1e1fefdb91883f108254c428b475daf51a7aa0b23f8642b468bf59ecbe946"

  url "https://d3fwkemdw8spx3.cloudfront.net/studio/SQLProStudio.#{version}.app.zip"
  name "SQLPro Studio"
  desc "Database management tool"
  homepage "https://www.sqlprostudio.com/"

  livecheck do
    url "https://www.sqlprostudio.com/download.php"
    strategy :header_match
  end

  depends_on macos: :sonoma

  app "SQLPro Studio.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/SQLPro Studio.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.hankinsoft.osx.sqlprostudio.sfl*",
    "~/Library/Containers/com.hankinsoft.osx.sqlprostudio",
  ]
end
