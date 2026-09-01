cask "routeconverter" do
  arch arm: "aarch64", intel: "x64"

  version "3.4.1"
  sha256 arm:   "968d1900456306fd5ba0d4adea74db6a0e52b01b975180272902603766ded45d",
         intel: "e0089f0d0c68542b887e3871df1a55db47777866ff29b5305a9777af3b61b61a"

  url "https://static.routeconverter.com/download/previous-releases/#{version}/RouteConverterMacOpenSource-#{arch}.app.zip"
  name "RouteConverter"
  desc "GPS tool to display, edit, enrich and convert routes, tracks and waypoints"
  homepage "https://www.routeconverter.com/"

  livecheck do
    url "https://static.routeconverter.com/download/previous-releases/"
    regex(/href=.*?v?(\d+(?:\.\d+)+)/i)
  end


  auto_updates true
  depends_on :macos

  app "RouteConverter.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.routeconverter"

  # The aarch64 zip contains the same Intel app as the x64 zip for now.
  caveats do
    requires_rosetta
  end
end
