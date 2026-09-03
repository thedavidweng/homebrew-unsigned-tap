cask "redquits" do
  version "2.0"
  sha256 :no_check

  url "https://redquits.s3.amazonaws.com/RedQuits_v#{version.major}.pkg"
  name "RedQuits"
  desc "Quit an app when closing the last window"
  homepage "http://carsten-mielke.com/redquits.html"

  livecheck do
    url :homepage
    regex(/RedQuits\s+v?(\d+(?:\.\d+)+)/i)
  end

  depends_on :macos

  pkg "RedQuits_v#{version.major}.pkg"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall pkgutil: "com.carsten-mielke.RedQuits"

  zap trash: "~/Library/Preferences/com.carsten-mielke.RedQuits.plist"
end
