cask "ubiquiti-unifi-controller" do
  version "10.6.109"
  sha256 "db4ff15d644daa72ac87f694c80392536953097bc6fb14e9e1198ef076f9e2f0"

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
