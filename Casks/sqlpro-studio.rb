cask "sqlpro-studio" do
  version "2026.238"
  sha256 "59f808e0ce1943d8720dea2aaa43d40b9a7989b910b984ce2b85dcc11337db27"

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

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.hankinsoft.osx.sqlprostudio.sfl*",
    "~/Library/Containers/com.hankinsoft.osx.sqlprostudio",
  ]
end
