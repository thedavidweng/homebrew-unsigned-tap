cask "nwjs" do
  arch arm: "arm64", intel: "x64"

  version "0.119.2"
  sha256 arm:   "a215af6f90e6daafff651e72a4711431f4aebed2516540a395a180d460168051",
         intel: "17ff04069fc39a09cc3c9c2f8bdf4e63656dde3a23cbeb1c16381a06acfc1c23"

  url "https://dl.nwjs.io/v#{version}/nwjs-sdk-v#{version}-osx-#{arch}.zip"
  name "NW.js"
  desc "Call all Node.js modules directly from the DOM and Web Workers"
  homepage "https://nwjs.io/"

  # The upstream download page appends a UNIX epoch timestamp (in milliseconds)
  # to the JSON URL, so we do the same (in case it affects the returned data).
  livecheck do
    url "https://nwjs.io/versions.json?#{DateTime.now.strftime("%Q")}"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :json do |json, regex|
      match = json["stable"]&.match(regex)
      next if match.blank?

      match[1]
    end
  end

  depends_on macos: :ventura

  app "nwjs-sdk-v#{version}-osx-#{arch}/nwjs.app"
  binary "nwjs-sdk-v#{version}-osx-#{arch}/nwjc"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/nwjs.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/nwjs",
    "~/Library/Caches/nwjs",
    "~/Library/Preferences/io.nwjs.nwjs.plist",
    "~/Library/Saved Application State/io.nwjs.nwjs.savedState",
  ]
end
