cask "tuxguitar" do
  version "2.1.1"
  sha256 "0d514395403ba9485eecad46696facf92f0512e7cf5900ea8f2383be36c8bcbd"

  url "https://github.com/helge17/tuxguitar/releases/download/#{version}/tuxguitar-#{version}-macosx-swt-cocoa-x86_64.app.tar.gz"
  name "TuxGuitar"
  desc "Multitrack guitar tablature editor and player"
  homepage "https://www.tuxguitar.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "tuxguitar-#{version}-macosx-swt-cocoa-x86_64.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-rd", "com.apple.quarantine", "{{appdir}}/tuxguitar-#{version}-macosx-swt-cocoa-x86_64.app"],
        must_succeed: false
  end

  uninstall quit: "app.tuxguitar"

  zap trash: "~/Library/Application Support/tuxguitar"
end
