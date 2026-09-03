cask "ultimate" do
  version "3.0.16.664"
  sha256 :no_check

  url "https://download.epubor.com/epubor_ultimate.zip"
  name "Epubor Ultimate"
  desc "Convert and remove DRM on eBooks"
  homepage "https://www.epubor.com/"

  livecheck do
    url "https://www.epubor.com/ultimate.html"
    regex(/Version:\s*v?(\d+(?:\.\d+)+).*?#os_Mac/i)
  end

  depends_on :macos

  pkg "Ultimate.pkg"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  uninstall pkgutil: "EpuborStudioUltimate2"

  zap trash: [
    "~/.Epubor_Keys",
    "~/.Ultimate",
    "~/EpuborLog",
    "~/Library/Preferences/Ultimate.plist",
    "~/Library/Saved Application State/Ultimate.savedState",
  ]
end
