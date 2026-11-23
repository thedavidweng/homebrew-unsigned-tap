cask "kindle-comic-converter" do
  arch arm: "arm", intel: "i386"

  version "13.0.4"
  sha256 arm:   "f1cbfe95b0e12b2386593d6b137a341b80673229f94c2973900a12335e19262f",
         intel: "96e8866a637ec88414f146e7aafe8770385466a54be6ed6002a03b55a249e7de"

  url "https://github.com/ciromattia/kcc/releases/download/v#{version}/kcc_macos_#{arch}_#{version}.dmg"
  name "Kindle Comic Converter"
  name "KCC"
  desc "Comic and manga converter for ebook readers"
  homepage "https://github.com/ciromattia/kcc"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Kindle Comic Converter.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/Kindle Comic Converter.app"],
        must_succeed: false
  end

  zap trash: "~/Library/Preferences/com.kindlecomicconverter.KindleComicConverter.plist"
end
