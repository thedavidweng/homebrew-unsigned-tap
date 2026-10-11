cask "dosbox-x-app" do
  arch arm: "arm64", intel: "x86_64"

  version "2026.10.01"
  sha256 arm:   "8514ab856e8ac2611fbdac7adf334c34085c1e00d700a88711f842adec50240f",
         intel: "a0605348355ff4a45c781f124c44122e97156ae3f7d048637f545c9de641bedb"

  url "https://github.com/joncampbell123/dosbox-x/releases/download/dosbox-x-v#{version.csv.first}/dosbox-x-macosx-#{arch}-#{version.csv.second || version.csv.first}.zip"
  name "DOSBox-X"
  desc "Fork of the DOSBox project"
  homepage "https://dosbox-x.com/"

  livecheck do
    url :homepage
    regex(%r{href=.*?v?(\d+(?:\.\d+)+)/dosbox-x-macosx?-#{arch}[._-]v?(\d+(?:\.\d+)+)\.zip}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map do |match|
        (match[0] == match[1]) ? match[0] : "#{match[0]},#{match[1]}"
      end
    end
  end

  depends_on :macos

  app "dosbox-x/dosbox-x.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/dosbox-x.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.dosbox-x.plist",
    "~/Library/Preferences/mapper-dosbox-x.map",
  ]
end
