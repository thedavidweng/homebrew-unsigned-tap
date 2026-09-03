cask "ubiquiti-unifi-controller" do
  version "10.6.101"
  sha256 "62aae907b989a34392f82818ce339829b441d59d40643e7d3c8c78b8e3d08fbb"

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

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
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
