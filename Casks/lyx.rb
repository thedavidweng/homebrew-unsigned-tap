cask "lyx" do
  version "2.5.3,6"
  sha256 "fd8cf48332bd1efb9e402ee2077816343c759875ba04def7082c3af14daa3943"

  url "https://ftp.lip6.fr/pub/lyx/bin/#{version.csv.first.major_minor_patch}/LyX-#{version.csv.first}+qt#{version.csv.second}-x86_64-arm64-cocoa.dmg"
  name "LyX"
  desc "GUI document processor based on the LaTeX typesetting system"
  homepage "https://www.lyx.org/"

  livecheck do
    url "https://ftp.lip6.fr/pub/lyx/bin/"
    regex(%r{href=["']v?(\d+(?:\.\d+)+)/["']}i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| "#{match.first},6" }
    end
  end

  depends_on macos: :monterey

  app "LyX.app"
  binary "#{appdir}/LyX.app/Contents/MacOS/inkscape", target: "lyx-inkscape"
  binary "#{appdir}/LyX.app/Contents/MacOS/lyx"
  binary "#{appdir}/LyX.app/Contents/MacOS/lyxclient"
  binary "#{appdir}/LyX.app/Contents/MacOS/lyxconvert"
  binary "#{appdir}/LyX.app/Contents/MacOS/lyxeditor"
  binary "#{appdir}/LyX.app/Contents/MacOS/maxima", target: "lyx-maxima"
  binary "#{appdir}/LyX.app/Contents/MacOS/tex2lyx"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/LyX.app"],
        must_succeed: false
  end

  uninstall quit: "org.lyx.lyx"

  zap trash: [
    "~/Library/Application Support/LyX-#{version.major_minor}",
    "~/Library/Caches/com.apple.python/Applications/LyX.app",
    "~/Library/Preferences/org.lyx.LyX-#{version.major_minor}.plist",
    "~/Library/Preferences/org.lyx.lyx.plist",
    "~/Library/Saved Application State/org.lyx.lyx.savedState",
  ]
end
