cask "futurerestore-gui" do
  version "1.98.3"
  sha256 "44d37f7d74393018b71c641dd98e229e78eb95915b4733aa586723856235c04f"

  url "https://github.com/CoocooFroggy/FutureRestore-GUI/releases/download/v#{version}/FutureRestore-GUI-Mac-#{version}.dmg"
  name "FutureRestore GUI"
  desc "Graphical interface for FutureRestore"
  homepage "https://github.com/CoocooFroggy/FutureRestore-GUI/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "FutureRestore GUI.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/FutureRestoreGUI"

  caveats do
    requires_rosetta
  end
end
