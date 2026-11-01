cask "ueli" do
  arch arm: "-arm64"

  on_monterey :or_older do
    version "9.29.0"
    sha256 arm:   "b6d10e9e86785bda386ecb0665e7b4e95a3a32b68b99d2769f47eeb3e6a97513",
           intel: "c0c31afac07bd93c1104cebf16bb127070be67155d17961bfbec43da1e6e3a5c"

    livecheck do
      skip "Legacy version for macOS Monterey"
    end

    depends_on macos: :monterey
  end
  on_ventura :or_newer do
    version "9.29.1"
    sha256 arm:   "fd6001a9a0195823b6a890d710f38f74f7f2f8a1b3e7dae5153aa17f43cb3453",
           intel: "269d2dc6c30536b4a1bbeeda2e9e3a56fcd06e288b9bb4c9eddacf44f7df12da"

    depends_on macos: :ventura
  end

  url "https://github.com/oliverschwendener/ueli/releases/download/v#{version}/Ueli-#{version}#{arch}.dmg"
  name "Ueli"
  desc "Keystroke launcher"
  homepage "https://ueli.app/"

  depends_on :macos

  app "Ueli.app", target: "ueli.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/ueli.app"],
        must_succeed: false
  end

  uninstall quit: "ueli"

  zap trash: [
    "~/Library/Application Support/ueli",
    "~/Library/Logs/ueli",
    "~/Library/Preferences/com.electron.ueli.plist",
  ]
end
