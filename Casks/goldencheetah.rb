cask "goldencheetah" do
  version "3.8"
  sha256 "b4f768d8f2c4bbc751e2f3a544dccc6f5b9c686e212476f524c56df03e14c735"

  url "https://github.com/GoldenCheetah/GoldenCheetah/releases/download/v#{version}/GoldenCheetah_v#{version}_x64.dmg"
  name "GoldenCheetah"
  desc "Performance software for cyclists, runners and triathletes"
  homepage "https://www.goldencheetah.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "GoldenCheetah.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/GoldenCheetah.app"],
        must_succeed: false
  end

  caveats do
    requires_rosetta
  end
end
