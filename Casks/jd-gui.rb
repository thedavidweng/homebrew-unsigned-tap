cask "jd-gui" do
  version "1.6.6"
  sha256 "b16ce61bbcfd2f006046b66c8896c512a36c6b553afdca75896d7c5e27c7477d"

  url "https://github.com/java-decompiler/jd-gui/releases/download/v#{version}/jd-gui-osx-#{version}.tar"
  name "JD-GUI"
  desc "Standalone Java Decompiler GUI"
  homepage "https://java-decompiler.github.io/"

  depends_on :macos

  app "jd-gui-osx-#{version}/JD-GUI.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-r", "-d", "com.apple.quarantine", staged_path.to_s]
  end

  zap trash: "~/Library/Saved Application State/jd.jd-gui.savedState"
end
