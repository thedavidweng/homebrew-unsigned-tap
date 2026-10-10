cask "routeconverter" do
  arch arm: "aarch64", intel: "x64"

  version "3.7"
  sha256 arm:   "63efa787a06e8cd4c8e2dc3ff233c945d56e0141c6295fb681db57a2ade6da8c",
         intel: "134563c895a9018921c01d04b5badc5577461656e34c21017de64e103a842077"

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
