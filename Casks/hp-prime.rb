cask "hp-prime" do
  version "2026-09-09"
  sha256 "8b4dfcee7ac564b7ce8fa989d69b6768f9238c4a3033237b7d8d664ab1fb604e"

  url "https://updates.moravia-consulting.com/HP_Prime_Virtual_Calculator_#{version.hyphens_to_underscores}.dmg"
  name "HP Prime"
  desc "Graphing calculator emulator"
  homepage "https://www.hp.com/us-en/calculators.html"

  livecheck do
    url "https://updates.moravia-consulting.com/"
    regex(/href=["']HP_Prime_Virtual_Calculator_(\d{4}_\d{2}_\d{2})\.dmg["']/i)
    strategy :page_match do |page, regex|
      page.scan(regex).map { |match| match.first.tr("_", "-") }
    end
  end

  depends_on :macos

  app "HP Prime.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/HP Prime.app"],
        must_succeed: false
  end

  caveats do
    requires_rosetta
  end
end
