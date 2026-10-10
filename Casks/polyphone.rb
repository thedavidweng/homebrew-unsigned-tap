cask "polyphone" do
  on_big_sur :or_older do
    version "2.5.1,130"
    sha256 "03b3509f8a6af45a7de6b93aeaf62bf5fae552aba7806b0ac46cf24ba57f37e3"

    "_MacOS_10.13"
  end
  macos_version = "-MacOS_12"

  on_monterey :or_newer do
    version "2.5.1,129"
    sha256 "89a60fc2444a4502719d23f2d5404a1fa9677db64ef09267ebced0eddf77a0dc"
  end

  url "https://www.polyphone.io/download/0/v#{version.csv.second}/Polyphone#{macos_version}-#{version.csv.first}.dmg",
      user_agent: :browser
  name "Polyphone"
  desc "Soundfont editor for quickly designing musical instruments"
  homepage "https://www.polyphone.io/en"

  livecheck do
    skip "macOS asset naming and download identifiers changed; pinned download returns HTTP 404"
  end

  depends_on :macos

  app "polyphone.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/polyphone.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/com.polyphone.Polyphone.plist",
    "~/Library/Saved Application State/fr.polyphone.Polyphone.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
