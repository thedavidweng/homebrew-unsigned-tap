cask "lemonlime" do
  arch arm: "arm64", intel: "x86_64"

  version "0.3.7,6.12.0"
  sha256 arm:   "2e2345c97d629f8ae18607a77fa987961f8c8a14de9d71911523cfb4d92526fb",
         intel: "b68a24a76780cc445988ea72a3504ebe29318ddb990e4d0deba7c1dc77b605b5"

  url "https://github.com/Project-LemonLime/Project_LemonLime/releases/download/#{version.csv.first}/lemon-Qt#{version.csv.second}-Release-#{arch}.dmg"
  name "lemonlime"
  desc "Tiny judging environment for OI contest based on Lemon + LemonPlus"
  homepage "https://github.com/Project-LemonLime/Project_LemonLime"

  livecheck do
    url :url
    regex(%r{/v?(\d+(?:\.\d+)+[a-z]?)/lemon(?:[._-]Qt(\d+(?:\.\d+)+))?(?:[._-]Release)?(?:[._-]#{arch})?\.dmg$}i)
    strategy :github_latest do |json, regex|
      json["assets"]&.map do |asset|
        match = asset["browser_download_url"]&.match(regex)
        next if match.blank?

        match[2] ? "#{match[1]},#{match[2]}" : match[1]
      end
    end
  end

  depends_on :macos

  app "lemon.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/lemon.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Documents/Project_LemonLime",
    "~/Library/Preferences/com.github.lemonlime.plist",
    "~/Library/Preferences/com.lemonlime.lemon.plist",
    "~/Library/Saved Application State/com.github.lemonlime.savedState",
  ]
end
