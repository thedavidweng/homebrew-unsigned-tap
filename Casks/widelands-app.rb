cask "widelands-app" do
  arch arm: "arm64", intel: "x86"

  version "1.3.1"
  sha256 arm:   "f68d29fbeaf2f61c4b94c91956bf454b65734937b7951fb116dd5692f320395c",
         intel: "7f01ec51081a397de05fb9094424d5a2a735ff12fa501a5fb725934f30adc301"

  url "https://github.com/widelands/widelands/releases/download/v#{version}/Widelands-#{version}-macOS12_#{arch}.dmg"
  name "Widelands"
  desc "Free real-time strategy game like Settlers II"
  homepage "https://www.widelands.org/"

  livecheck do
    url :url
    regex(/^Widelands[._-]v?(\d+(?:\.\d+)+)[._-]macOS12[._-]#{arch}\.dmg$/i)
    strategy :github_releases do |releases, regex|
      releases.reject { |release| release["draft"] || release["prerelease"] }.flat_map do |release|
        release["assets"].filter_map { |asset| asset["name"][regex, 1] }
      end
    end
  end

  depends_on :macos

  app "Widelands.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Widelands.app"],
        must_succeed: false
  end

  zap trash: "~/.widelands"
end
