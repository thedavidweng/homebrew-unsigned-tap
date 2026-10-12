cask "saoimageds9" do
  # NOTE: "9" is not a version number, but an intrinsic part of the product name
  minimum_macos = :big_sur

  on_big_sur do
    arch arm: "arm64", intel: "x86"

    version "8.5"
    sha256 arm:   "b50a92cc729e5054aaf511911a189dea9cd13c4f6685a53c404b77efbc071854",
           intel: "46917bdab7fd22cb4cfd85145e9813c59e03dc1468f961172ad5ca396616fbb4"

    url "https://ds9.si.edu/archive/macosbigsur#{arch}/SAOImageDS9%20#{version}.dmg"

    livecheck do
      skip "Archived Big Sur release"
    end
  end
  on_monterey :or_newer do
    version "8.8"
    sha256 "6c70f3ea440a38e5aa4f2a73113c32de50e11cd9fab7dd5f0fbf45bc9465c5ec"

    url "https://ds9.si.edu/download/macos_universal/SAOImageDS9%20#{version}.dmg"

    livecheck do
      url "https://sites.google.com/cfa.harvard.edu/saoimageds9/download"
      regex(%r{href=.*?macos_universal/SAOImageDS9%20v?(\d+(?:\.\d+)+)\.dmg}i)
    end

    minimum_macos = :monterey
  end

  name "SAOImage DS9"
  desc "Astronomical data visualisation tool"
  homepage "https://sites.google.com/cfa.harvard.edu/saoimageds9/home"

  depends_on macos: minimum_macos

  app "SAOImageDS9.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/SAOImageDS9.app"],
        must_succeed: false
  end

  zap trash: [
    "~/.ds9",
    "~/Library/Preferences/com.sao.SAOImageDS9.plist",
    "~/Library/Saved Application State/com.sao.SAOImageDS9.savedState",
  ]
end
