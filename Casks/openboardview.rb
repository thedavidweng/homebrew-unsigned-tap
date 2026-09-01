cask "openboardview" do
  version "10.0.0"
  sha256 "236730f93853383e3df8dc451752ae33dbf39d31467f4a696137e8b78f473e7b"

  url "https://github.com/OpenBoardView/OpenBoardView/releases/download/#{version}/OpenBoardView-#{version}-Darwin.dmg"
  name "OpenBoardView"
  desc "File viewer for .brd files"
  homepage "https://openboardview.org/"

  livecheck do
    url :url
    strategy :github_latest
  end


  depends_on :macos

  app "openboardview.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Application Support/OpenBoardView"

  caveats do
    requires_rosetta
  end
end
