cask "dmenu-mac" do
  on_monterey :or_older do
    version "0.7.2"
    sha256 "db82a9ac07e1fca23e31db2e458979d12fce846a8948e5a053fd8d317967e469"

    livecheck do
      skip "Pinned release for macOS Monterey and older"
    end
  end
  on_ventura :or_newer do
    version "0.8.0"
    sha256 "e922338acc509a35882026fb66f6b94679e588cd867fa4eb5729420b6c59a8b0"
  end

  url "https://github.com/oNaiPs/dmenu-mac/releases/download/#{version}/dmenu-mac.zip"
  name "dmenu-mac"
  desc "Keyboard-only application launcher"
  homepage "https://github.com/oNaiPs/dmenu-mac"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "dmenu-mac.app"
  binary "#{appdir}/dmenu-mac.app/Contents/Resources/dmenu-mac"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/dmenu-mac.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Scripts/com.onaips.dmenu-macos",
    "~/Library/Containers/com.onaips.dmenu-macos",
  ]
end
