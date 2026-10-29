cask "mindforger" do
  version "2.6.0,20261028.170459"
  sha256 "efc990e09ef001a3b8bf4b139a30fb8c768c9bc5bf42fc78dd1ff7d50b19c992"

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
