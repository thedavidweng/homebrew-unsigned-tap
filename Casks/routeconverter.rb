cask "routeconverter" do
  arch arm: "aarch64", intel: "x64"

  version "3.8"
  sha256 arm:   "84ebc46d9053637f5cf8c731c9f6bc7e1680540ee754f64078e79e9c976278de",
         intel: "2ed35272cd7e589c561a614a334aaef1d40c27dea03bd87bbbabc55a9c1c84bc"

  url "https://releases.routeconverter.com/previous-releases/#{version}/RouteConverterMac-#{arch}.app.zip"
  name "RouteConverter"
  desc "GPS tool to display, edit, enrich and convert routes, tracks and waypoints"
  homepage "https://www.routeconverter.com/"

  livecheck do
    url "https://www.routeconverter.com/downloads/"
    regex(/RouteConverter\s+v?(\d+(?:\.\d+)+)\s*[·<]/i)
  end

  auto_updates true
  depends_on :macos

  app "RouteConverter.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/RouteConverter.app"],
        must_succeed: false
  end

  zap trash: "~/.routeconverter"
end
