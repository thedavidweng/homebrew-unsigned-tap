cask "plotdigitizer" do
  version "2.6.12b"
  sha256 "ea547e274744cac653dcddd299fcc876c4522f922d663febaded88752efc3a7f"

  url "https://downloads.sourceforge.net/plotdigitizer/plotdigitizer/#{version}/PlotDigitizer_MacOS.dmg"
  name "Plot Digitizer"
  desc "Digitize scanned plots of functional data"
  homepage "https://plotdigitizer.sourceforge.net/"

  livecheck do
    url "https://sourceforge.net/projects/plotdigitizer/rss?path=/plotdigitizer"
    regex(%r{url=.*?/v?(\d+(?:\.\d+)+[a-z]?)/PlotDigitizer(?:[._-]v?\d+(?:\.\d+)+)?[._-]MacOSX?\.dmg}i)
  end

  depends_on :macos

  app "Plot Digitizer.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Plot Digitizer.app"],
        must_succeed: false
  end

  zap :not_required
end
