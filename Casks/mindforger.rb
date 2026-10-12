cask "mindforger" do
  version "2.5.0,20260926.191335"
  sha256 "4b01c0e84a8d1aea7b94348d39142620bae982af3bf9c97dda55543453bbfa89"

  url "https://github.com/dvorka/mindforger/releases/download/#{version.csv.first}/mindforger-#{version.csv.first}-#{version.csv.second}-intel.dmg"
  name "MindForger"
  desc "Thinking notebook and Markdown IDE"
  homepage "https://www.mindforger.com/"

  livecheck do
    url :url
    regex(/^mindforger[._-]v?(\d+(?:\.\d+)+)[._-](\d{8}\.\d{6})[._-]intel\.dmg$/i)
    strategy :github_releases do |releases, regex|
      releases.reject { |release| release["draft"] || release["prerelease"] }.flat_map do |release|
        release["assets"].flat_map { |asset| asset["name"].scan(regex).map { |match| match.join(",") } }
      end
    end
  end

  depends_on :macos

  app "mindforger.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/mindforger.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.local/share/MindForger",
    "~/.mindforger.md",
    "~/Library/Application Support/MindForger",
    "~/Library/Saved Application State/com.yourcompany.mindforger.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
