cask "zenmap" do
  version "7.992"
  sha256 "036559c57d66f828cef9980af03d6c8faa579edced920bf7f6464f29a89114e3"

  url "https://nmap.org/dist/nmap-#{version}.dmg"
  name "Zenmap"
  desc "Multi-platform graphical interface for official Nmap Security Scanner"
  homepage "https://nmap.org/zenmap/"

  livecheck do
    url "https://nmap.org/download.html"
    regex(/href=.*?nmap[._-]v?(\d+(?:\.\d+)+)\.dmg/i)
  end

  depends_on :macos

  pkg "nmap-#{version}.mpkg"

  uninstall pkgutil: [
              "org.insecure.nmap",
              "org.insecure.nmap.ncat",
              "org.insecure.nmap.ndiff",
              "org.insecure.nmap.nping",
              "org.insecure.nmap.zenmap",
            ],
            delete:  "/Applications/Zenmap.app"

  zap trash: [
    "~/.zenmap",
    "~/Library/Saved Application State/org.insecure.Zenmap.savedState",
  ]
end
