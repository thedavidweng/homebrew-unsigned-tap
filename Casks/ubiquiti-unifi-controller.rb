cask "ubiquiti-unifi-controller" do
  version "10.6.106"
  sha256 "1a8bce73cb4bdb12bb9911b38a3c086f9fe827f4933601308913d2fc44ee268a"

  url "https://dl.ubnt.com/unifi/#{version}/UniFi-Network-Server.dmg"
  name "Ubiquiti UniFi Network Controller"
  desc "Set up, configure, manage and analyze your UniFi network"
  homepage "https://www.ui.com/"

  livecheck do
    url "https://fw-update.ubnt.com/api/firmware-latest?filter=eq~~product~~unifi-controller&filter=eq~~channel~~release&filter=eq~~platform~~macos"
    regex(/^\D*?(\d+(?:\.\d+)+)/i)
    strategy :json do |json, regex|
      json.dig("_embedded", "firmware")&.filter_map do |item|
        item["version"]&.[](regex, 1)
      end
    end
  end

  depends_on :macos

  app "UniFi.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/UniFi.app"],
        must_succeed: false
  end

  uninstall signal: ["TERM", "com.ubnt.UniFi"]

  zap trash: [
    "~/Library/Application Support/UniFi",
    "~/Library/Saved Application State/com.ubnt.UniFi-Discover.savedState",
    "~/Library/Saved Application State/com.ubnt.UniFi.savedState",
  ]

  caveats do
    requires_rosetta
    license "https://www.ui.com/eula/"
  end
end
