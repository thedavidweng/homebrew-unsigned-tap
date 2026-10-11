cask "mysqlworkbench" do
  version "26.7.0"
  sha256 "063cd888335ba81343092f9fe6568c786f02aa9e82fb1752688738d534fb2004"

  url "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-#{version}-macos-arm64.dmg"
  name "MySQL Workbench"
  desc "Visual tool to design, develop and administer MySQL servers"
  homepage "https://dev.mysql.com/downloads/workbench/"

  livecheck do
    url "https://dev.mysql.com/downloads/workbench/?tpl=platform&os=33",
        user_agent: :curl
    regex(/mysql[._-]workbench[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-]arm64\.dmg/i)
  end

  conflicts_with cask: "mysqlworkbench@legacy"
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "MySQL Workbench.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/MySQL Workbench.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/MySQL Workbench",
    "~/Library/Caches/com.oracle.mysqlworkbench",
    "~/Library/Preferences/com.oracle.mysqlworkbench.plist",
    "~/Library/Saved Application State/com.oracle.mysqlworkbench.savedState",
  ]
end
