cask "keepassxc@snapshot" do
  version "2.8.0,299252"
  sha256 "809227cf8076ab905689a91863dbb858b7e0f1f522b9478309d012b5d4d96653"

  url "https://snapshot.keepassxc.org/build-#{version.csv.second}/KeePassXC-#{version.csv.first}-snapshot.dmg"
  name "KeePassXC"
  desc "Password manager app"
  homepage "https://keepassxc.org/"

  livecheck do
    url "https://snapshot.keepassxc.org/"
    regex(/href=["']?KeePassXC[._-]v?(\d+(?:\.\d+)+)[._-]snapshot\.dmg["' >]/i)
    strategy :page_match do |page, regex|
      build = page.scan(%r{href=["']build-(\d+)/["']}i).flatten.map(&:to_i).max
      next if build.blank?

      build_page = Homebrew::Livecheck::Strategy.page_content("https://snapshot.keepassxc.org/build-#{build}/")[:content]
      next if build_page.blank?

      match = build_page.match(regex)
      next if match.blank?

      "#{match[1]},#{build}"
    end
  end

  conflicts_with cask: [
    "keepassxc",
    "keepassxc@beta",
  ]
  depends_on macos: :sonoma

  app "KeePassXC.app"
  binary "#{appdir}/KeePassXC.app/Contents/MacOS/keepassxc-cli"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/KeePassXC.app"],
        must_succeed: false
  end

  uninstall quit: "org.keepassxc.keepassxc"

  zap trash: [
    "~/.keepassxc",
    "~/Library/Application Support/CrashReporter/KeePassXC_*.plist",
    "~/Library/Application Support/keepassxc",
    "~/Library/Caches/org.keepassx.keepassxc",
    "~/Library/Logs/DiagnosticReports/KeePassXC_*.crash",
    "~/Library/Preferences/keepassxc.keepassxc.plist",
    "~/Library/Preferences/org.keepassx.keepassxc.plist",
    "~/Library/Saved Application State/org.keepassx.keepassxc.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
