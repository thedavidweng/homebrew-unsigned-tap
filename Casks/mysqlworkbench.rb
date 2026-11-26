cask "mysqlworkbench" do
  version "26.10.0.1"
  sha256 "5c44ece5fc7785c559d025d88d583ab51eb4b398851d46294a9c8c4f26548897"

  url "https://cdn.mysql.com/Downloads/MySQLGUITools/mysql-workbench-#{version}-macos-arm64.dmg"
  name "MySQL Workbench"
  desc "Visual tool to design, develop and administer MySQL servers"
  homepage "https://github.com/mysql/mysql-shell-plugins"

  livecheck do
    url "https://dev.mysql.com/downloads/workbench/?tpl=platform&os=33",
        user_agent: :curl
    regex(/mysql[._-]workbench[._-]v?(\d+(?:\.\d+)+)[._-]macos[._-]arm64\.dmg/i)
  end

  conflicts_with cask: "mysqlworkbench@legacy"
  depends_on arch: :arm64
  depends_on macos: :ventura

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

  caveats do
    "Oracle lists macOS 14 or later as supported for this release; the binary minimum is macOS 12."
  end
end
