cask "routeconverter" do
  arch arm: "aarch64", intel: "x64"

  version "3.6"
  sha256 arm:   "fe375a2078588f6e3885cf39363c38abf90d3492d0044e2dbaa9886ab280918a",
         intel: "6149b8198ad126b5eb91cc810b6a70b90221fab019573c0c00361484c9bf927e"

  url "https://releases.routeconverter.com/previous-releases/#{version}/RouteConverterMac-#{arch}.app.zip"
  name "RouteConverter"
  desc "GPS tool to display, edit, enrich and convert routes, tracks and waypoints"
  homepage "https://www.routeconverter.com/"

  livecheck do
    url "https://releases.routeconverter.com/previous-releases/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  auto_updates true
  depends_on :macos

  app "RouteConverter.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/.routeconverter"
end
